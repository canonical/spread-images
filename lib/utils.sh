#!/bin/bash

clean_machine() {
	case "$SPREAD_SYSTEM" in
		ubuntu-*|debian-*)
			apt-get clean
			apt-get autoremove -y
			find \
				/var/cache/apt \
				/var/lib/apt/{lists,mirrors} \
				-type f -exec rm -f {} \;
			;;
		fedora-*)
			dnf clean all
			dnf -q -y autoremove || true
			find \
				/var/cache/dnf \
				-type f -exec rm -f {} \;

			if [ -d /mnt/disk/var/lib/dnf/history ]; then
				find \
				/var/lib/dnf/{history,yumdb} \
				-type f -exec rm -f {} \;
			else
				rm -f /mnt/disk/var/lib/dnf/history.*
			fi
			;;
		opensuse-*)
			zypper -q clean --all
			if [ -d /var/cache/zypper ]; then
				find \
					/var/cache/zypper \
					-type f -exec rm -f {} \;
			fi
			;;
		arch-*)
    		pacman -Scc --noconfirm
	    	;;
		amazon-*|centos-*)
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
