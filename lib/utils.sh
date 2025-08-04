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
    CRONY_SOURCES=$(find /etc/chrony -name ubuntu-ntp-pools.sources)
    if [ -f "$CRONY_SOURCES" ]; then
        sed -i -e "/^pool.*/d" "$CRONY_SOURCES"
        echo "pool $NTP_SERVER iburst" >> "$CRONY_SOURCES"
    fi
}

setup_ntp_chrony() {
    distro_install_package chrony
    setup_chrony_config
    setup_chrony_sources

    systemctl restart chrony
    for _ in $(seq 10); do
        if systemctl is-active chrony | grep active; then
            return
        fi
        sleep 1
    done
    timedatectl set-ntp yes
    for _ in $(seq 30); do
        if timedatectl status | grep -E "clock synchronized:.*yes"; then
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
    cp "$CONF_FILE" "${CONF_FILE}.bak.$(date +%F_%T)"

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
