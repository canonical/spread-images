#!/bin/bash

if [ ! -z "$TMP_IMAGE_ID" ]; then
    IMAGE="tmp-$TMP_IMAGE_ID"
    FAMILY="tmp-$TMP_IMAGE_ID"
    DESCRIPTION="tmp-$TMP_IMAGE_ID"
else
    case "$TARGET_SYSTEM" in
    # Ubuntu
        ubuntu-14.04-64)
            IMAGE="ubuntu-1404-64-v$(date +'%Y%m%d')"
            FAMILY="ubuntu-1404-64"
            DESCRIPTION="Ubuntu 14.04 64 bits"
            ;;
        ubuntu-16.04-32-base)
            IMAGE="ubuntu-1604-32-base-v$(date +'%Y%m%d')"
            FAMILY="ubuntu-1604-32-base"
            DESCRIPTION="Base image"
            ;;
        ubuntu-16.04-32)
            IMAGE="ubuntu-1604-32-v$(date +'%Y%m%d')"
            FAMILY="ubuntu-1604-32"
            DESCRIPTION="Ubuntu 16.04 32 bits"
            ;;
        ubuntu-16.04-64)
            IMAGE="ubuntu-1604-64-v$(date +'%Y%m%d')"
            FAMILY="ubuntu-1604-64"
            DESCRIPTION="Ubuntu 16.04 64 bits"
            ;;
        ubuntu-18.04-64)
            IMAGE="ubuntu-1804-64-v$(date +'%Y%m%d')"
            FAMILY="ubuntu-1804-64"
            DESCRIPTION="Ubuntu 18.04 64 bits"
            ;;
        # Debian
        debian-9-64)
            IMAGE="debian-9-64-v$(date +'%Y%m%d')"
            FAMILY="debian-9-64"
            DESCRIPTION="Debian 9 64 bits"
            ;;
        debian-sid-64-base)
            IMAGE="debian-sid-64-base-v$(date +'%Y%m%d')"
            FAMILY="debian-sid-64-base"
            DESCRIPTION="Base image"
            ;;
        debian-sid-64)
            IMAGE="debian-sid-64-v$(date +'%Y%m%d')"
            FAMILY="debian-sid-64"
            DESCRIPTION="Debian sid 64 bits"
            ;;
        # Fedora
        fedora-26-64)
            IMAGE="fedora-26-64-v$(date +'%Y%m%d')"
            FAMILY="fedora-26-64"
            DESCRIPTION="Base Fedora 26 64 bits"
            ;;
        fedora-27-64-base)
            IMAGE="fedora-27-64-base-v$(date +'%Y%m%d')"
            FAMILY="fedora-27-64-base"
            DESCRIPTION="Base image"
            ;;
        fedora-27-64)
            IMAGE="fedora-27-64-v$(date +'%Y%m%d')"
            FAMILY="fedora-27-64"
            DESCRIPTION="Fedora 27 64 bits with SELinux permissive and test dependencies"
            ;;
        fedora-28-64-base)
            IMAGE="fedora-28-64-base-v$(date +'%Y%m%d')"
            FAMILY="fedora-28-64-base"
            DESCRIPTION="Base image"
            ;;
        fedora-28-64)
            IMAGE="fedora-28-64-v$(date +'%Y%m%d')"
            FAMILY="fedora-28-64"
            DESCRIPTION="Fedora 28 64 bits with test dependencies"
            ;;
        # Arch Linux
        arch-linux-64-base)
            IMAGE="arch-linux-64-base-v$(date +'%Y%m%d')"
            FAMILY="arch-linux-64-base"
            DESCRIPTION="Base image"
            ;;
        arch-linux-64)
            IMAGE="arch-linux-64-v$(date +'%Y%m%d')"
            FAMILY="arch-linux-64"
            DESCRIPTION="Arch Linux 64 bits with test dependencies"
            ;;
        # Opensuse
        opensuse-42.2-64-base)
            IMAGE="opensuse-leap-42-2-64-base-v$(date +'%Y%m%d')"
            FAMILY="opensuse-leap-42-2-64-base"
            DESCRIPTION="Base image"
            ;;
        opensuse-42.2-64)
            IMAGE="opensuse-leap-42-2-64-v$(date +'%Y%m%d')"
            FAMILY="opensuse-leap-42-2-64"
            DESCRIPTION="Opensuse leap 42.2 64 bits with test dependencies"
            ;;
        opensuse-42.3-64)
            IMAGE="opensuse-leap-42-3-64-v$(date +'%Y%m%d')"
            FAMILY="opensuse-leap-42-3-64"
            DESCRIPTION="Opensuse leap 42.3 64 bits"
            ;;
        # Amazon linux 2
        amazon-linux-2-64-base)
            IMAGE="amazon-linux-2-64-base-v$(date +'%Y%m%d')"
            FAMILY="amazon-linux-2-64-base"
            DESCRIPTION="Base image"
            ;;
        amazon-linux-2-64)
            IMAGE="amazon-linux-2-64-v$(date +'%Y%m%d')"
            FAMILY="amazon-linux-2-64"
            DESCRIPTION="Amazon Linux 2 64 bits"
            ;;
        *)
            echo "ERROR: Unsupported distribution '$SPREAD_SYSTEM'"
            exit 1
            ;;
    esac
fi

case "$SPREAD_SYSTEM" in
    arch-*)
        DISK="$(dhcpcd -T | sed -n 's/new_host_name=\(.*\).c.computeengine.internal/\1/gp')"
        ;;
    *)
        DISK="$(hostname)"
        ;;
esac

export IMAGE
export FAMILY
export DESCRIPTION
export DISK
