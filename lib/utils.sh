#!/bin/bash

. "$TESTSLIB/pkgdb.sh"

clean_machine() {
    distro_auto_remove_packages
    distro_clean_package_cache

    find /var/log -type f -exec rm -f {} \;
    mkdir -p /var/log/journal

    rm -rf \
        /root/.bash_history \
        /root/.viminfo \
        /root/.cache

    sync
}

update_ntp() {
    if [ -n "${NTP_SERVER:-}" ]; then
        setup_ntp_timesyncd
        # This is the default so we configure it at last
        setup_ntp_chrony 
    fi
}

setup_chrony_config() {
    if [ -d /etc/chrony.d ]; then
        # drop in snippets under /etc/chrony.d - e.g. openSUSE
        echo "pool $NTP_SERVER iburst" > /etc/chrony.d/snapd-ntp-pool.conf
        return
    fi

    CRONY_CONF=/etc/chrony/chrony.conf
    if [ -f /etc/chrony.conf ]; then
        CRONY_CONF=/etc/chrony.conf
    fi
    # Never write the vendor config in /usr/etc; if there is no config under
    # /etc to edit the drop-in above should have applied instead.
    if [ ! -f "$CRONY_CONF" ]; then
        echo "ERROR: no chrony config in /etc and no drop-in snippets support" >&2
        exit 1
    fi

    # When Running in PS7+, Configure ntp to the $NTP_SERVER
    sed -i -e "s/^pool.*/pool $NTP_SERVER iburst/g" "$CRONY_CONF"
    sed -i -e "s/^#pool.*/pool $NTP_SERVER iburst/g" "$CRONY_CONF"
    # Also uncomment any disabled pool lines
    sed -i -e "s/^! pool.*/pool $NTP_SERVER iburst/g" "$CRONY_CONF"
}

get_chrony_etc_sources_dir(){
    for f in  /usr/etc/chrony.conf /etc/chrony/chrony.conf /etc/chrony.conf; do
        if [ -f "$f" ]; then
            CHRONY_CONF="$f"
        fi
    done

    [ -n "${CHRONY_CONF-}" ] || return
    grep -E '^sourcedir' $CHRONY_CONF | grep /etc/ | awk '{print $2}'
}


setup_chrony_sources(){
    chrony_usr_dir=/usr/share/chrony
    chrony_sources_dir="$(get_chrony_etc_sources_dir)"
    
    # Update sources found in /etc sources dir
    if [ -n "$chrony_sources_dir" ] && [ -d "$chrony_sources_dir" ]; then
        CHRONY_SOURCES="$(find "$chrony_sources_dir" -type f -name *.sources)"
        for chrony_source in $CHRONY_SOURCES; do
            sed -i -e "s/^pool /#pool /g" "$chrony_source"
            echo "pool $NTP_SERVER iburst" >> "$chrony_source"
            sed -i -e "s/^server /#server /g" "$chrony_source"
        done
    fi

    # Update sources found in /usr sources dir
    if [ -d "$chrony_usr_dir" ]; then
        CHRONY_USR_SOURCES="$(find "$chrony_usr_dir" -type f -name *.sources)"
        for chrony_usr_source in $CHRONY_USR_SOURCES; do
            updated=false
            if grep '^pool ' "$chrony_usr_source"; then
                sed -i -e "s/^pool /#pool /g" "$chrony_usr_source"
                echo "pool $NTP_SERVER iburst" >> "$chrony_usr_source"
                updated=true
            fi
            if grep '^server ' "$chrony_usr_source"; then
                sed -i -e "s/^server /#server /g" "$chrony_usr_source"
            fi
            if [ "$updated" = true ]; then                                
                mkdir -p "$chrony_sources_dir"                    
                cp -f "$chrony_usr_source" "$chrony_sources_dir"/snapd-ntp-pool.sources
                rm -f "$chrony_usr_source"/*.sources
                break
            fi
        done
    fi

    # Remove any sources link in /run which could fail to ln when the service is started
    for chrony_run_dir in /run/chrony /run/chrony.d /run/chrony-dhcp; do
        if [ ! -d "$chrony_run_dir" ]; then
            continue
        fi
        CHRONY_RUN_SOURCES="$(find "$chrony_run_dir" -type l -name *.sources)"
        for chrony_source in $CHRONY_RUN_SOURCES; do
            rm -f "$chrony_source"
        done
    done    
}

setup_ntp_chrony() {
    distro_install_package chrony

    service=chrony.service
    if ! systemctl -l | grep -q "$service"; then
        service=chronyd.service
    fi

    systemctl stop "$service"
    setup_chrony_config
    setup_chrony_sources
    systemctl start "$service"

    for _ in $(seq 10); do
        if systemctl is-active "$service" | grep -E "^active"; then
            break
        fi
        sleep 1
    done

    timedatectl set-ntp yes || true
    for _ in $(seq 30); do
        if timedatectl status | grep -E "synchronized:.*yes"; then
            return
        fi
        sleep 1
    done

    echo "Clock not synchronized"
    return 1
}

setup_ntp_timesyncd(){
    if [ ! -f /etc/systemd/timesyncd.conf ]; then
        echo "Configuration file timesyncd.conf not found, skipping..."
        return
    fi

    CONF_FILE="/etc/systemd/timesyncd.conf"

    # Backup the original file
    cp "$CONF_FILE" "${CONF_FILE}.bak"

    # Update or add NTP= line
    sed -i '/^NTP=/d' "$CONF_FILE"
    sed -i '/^\[Time\]/a NTP='"$NTP_SERVER" "$CONF_FILE"

    # Update or add FallbackNTP= line
    sed -i '/^FallbackNTP=/d' "$CONF_FILE"
    sed -i '/^\[Time\]/a FallbackNTP=' "$CONF_FILE"

    # Restart and enable the service
    systemctl restart systemd-timesyncd
    systemctl enable systemd-timesyncd
}
