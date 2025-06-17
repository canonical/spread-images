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

setup_chrony() {
    distro_install_package chrony
    if [ -n "${NTP_SERVER:-}" ]; then
        CRONY_CONF=/etc/chrony/chrony.conf
        if [ -f /etc/chrony.conf ]; then
            CRONY_CONF=/etc/chrony.conf
        fi

        # When Running in PS7+, Configure ntp to the $NTP_SERVER
        sed -i -e "s/^pool.*/pool $NTP_SERVER iburst/g" "$CRONY_CONF"
        sed -i -e "s/^#pool.*/pool $NTP_SERVER iburst/g" "$CRONY_CONF"

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
    fi
}