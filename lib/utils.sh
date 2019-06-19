#!/bin/bash

clean_machine() {
	find /var/log -type f -exec rm -f {} \;

    rm -rf \
        /root/.bash_history \
        /root/.viminfo \
        /root/.cache
}
