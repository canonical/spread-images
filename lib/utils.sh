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
    CRONY_CONF=/etc/chrony/chrony.conf
    if [ -f /etc/chrony.conf ]; then
        CRONY_CONF=/etc/chrony.conf
    fi

    # When Running in PS7+, Configure ntp to the $NTP_SERVER
    sed -i -e "s/^pool.*/pool $NTP_SERVER iburst/g" "$CRONY_CONF"
    sed -i -e "s/^#pool.*/pool $NTP_SERVER iburst/g" "$CRONY_CONF"
}

setup_chrony_sources(){
    chrony_dir=/usr/share/chrony
    if [ -d "$chrony_dir" ]; then
        CRONY_SOURCES="$(find "$chrony_dir" -type f -name *.sources)"
        for source_file in $CRONY_SOURCES; do
            updated=false
            if grep '^pool ' "$source_file"; then
                sed -i -e "s/^pool /#pool /g" "$source_file"
                echo "pool $NTP_SERVER iburst" >> "$source_file"
                updated=true
            fi
            if grep '^server ' "$source_file"; then
                sed -i -e "s/^server /#server /g" "$source_file"
            fi
            if [ "$updated" = true ]; then
                cp -f "$source_file" /etc/chrony.d/snapd-ntp-pool.sources
                break
            fi
        done
    fi

    # Remove any sources link in /run which could fail to ln when the service is started
    for chrony_run_dir in /run/chrony /run/chrony.d; do
        if [ ! -d "$chrony_run_dir" ]; then
            continue
        fi
        CRONY_SOURCES="$(find "$chrony_run_dir" -type l -name *.sources)"
        for source_file in $CRONY_SOURCES; do
            rm -f "$source_file"
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
