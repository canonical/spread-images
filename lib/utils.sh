#!/bin/bash

clean_machine() {
	case "$SPREAD_SYSTEM" in
		ubuntu-*|debian-*)
			apt autoremove -y
			find \
				/var/cache/apt \
				/var/lib/apt/{lists,mirrors} \
				-type f -exec rm -f {} \;
			;;
		fedora-*)
			dnf -q -y autoremove
			find \
				/var/cache/dnf \
				/var/lib/dnf/{history,yumdb} \
				-type f -exec rm -f {} \;
			;;
		opensuse-*)
			zypper -q clean --all
			find \
				/var/cache/zypper \
				-type f -exec rm -f {} \;
			;;
		arch-*)
    		pacman -Scc --noconfirm
	    	;;
		amazon-*)
			yum clean all
			;;
		*)
			echo "ERROR: Unsupported distribution '$SPREAD_SYSTEM'"
			exit 1
			;;
	esac

	find /var/log -type f -exec rm -f {} \;

    rm -rf \
        /root/.bash_history \
        /root/.viminfo \
        /root/.cache
}
