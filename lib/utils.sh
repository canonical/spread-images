#!/bin/bash

clean_machine() {
	case "$SPREAD_SYSTEM" in
		ubuntu-*|debian-*)
			apt autoremove -y
			find \
				/var/log \
				/var/cache/apt \
				/var/lib/apt/{lists,mirrors} \
				-type f -exec rm -f {} \;
			;;
		fedora-*)
			dnf -q -y autoremove
				find \
				/var/log \
				/var/cache/dnf \
				/var/lib/dnf/{history,yumdb} \
				-type f -exec rm -f {} \;
			;;
		opensuse-*)
			find \
				/var/log \
				/var/cache/zypper \
				-type f -exec rm -f {} \;
			;;
		*)
			echo "ERROR: Unsupported distribution '$SPREAD_SYSTEM'"
			exit 1
			;;
	esac

    rm -rf \
    	/root/.bash_history \
    	/root/.viminfo \
		/root/.bashrc \
	    /root/.cache
}