#!/bin/bash

. "$TESTSLIB/pkgdb.sh"

clean_machine() {
    distro_clean_package_cache

    find /var/log -type f -exec rm -f {} \;

    rm -rf \
        /root/.bash_history \
        /root/.viminfo \
        /root/.cache
}
