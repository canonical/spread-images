#!/bin/bash

case "$TARGET_SYSTEM" in
    # Ubuntu
    ubuntu-14.04-64)
        IMAGE="ubuntu-1404-64-v$(date +'%Y%m%d')"
        FAMILY="ubuntu-1404-64"
        DESCRIPTION="Ubuntu 14.04 64 bits"
        DISK="$(hostname)"
        ;;
    ubuntu-16.04-32-base)
        IMAGE="ubuntu-1604-32-base-v$(date +'%Y%m%d')"
        FAMILY="ubuntu-1604-32-base"
        DESCRIPTION="Base image"
        DISK="$(hostname)"
        ;;
    ubuntu-16.04-32)
        IMAGE="ubuntu-1604-32-v$(date +'%Y%m%d')"
        FAMILY="ubuntu-1604-32"
        DESCRIPTION="Ubuntu 16.04 32 bits"
        DISK="$(hostname)"
        ;;
    ubuntu-16.04-64)
        IMAGE="ubuntu-1604-64-v$(date +'%Y%m%d')"
        FAMILY="ubuntu-1604-64"
        DESCRIPTION="Ubuntu 16.04 64 bits"
        DISK="$(hostname)"
        ;;
    ubuntu-18.04-64)
        IMAGE="ubuntu-1804-64-v$(date +'%Y%m%d')"
        FAMILY="ubuntu-1804-64"
        DESCRIPTION="Ubuntu 18.04 64 bits"
        DISK="$(hostname)"
        ;;
    # Debian
    debian-9-64)
        IMAGE="debian-9-64-v$(date +'%Y%m%d')"
        FAMILY="debian-9-64"
        DESCRIPTION="Debian 9 64 bits"
        DISK="$(hostname)"
        ;;
    debian-sid-64-base)
        IMAGE="debian-sid-64-base-v$(date +'%Y%m%d')"
        FAMILY="debian-sid-64-base"
        DESCRIPTION="Base image"
        DISK="$(hostname)"
        ;;
    debian-sid-64)
        IMAGE="debian-sid-64-v$(date +'%Y%m%d')"
        FAMILY="debian-sid-64"
        DESCRIPTION="Debian sid 64 bits"
        DISK="$(hostname)"
        ;;
    # Fedora
    fedora-26-64)
        IMAGE="fedora-26-64-v$(date +'%Y%m%d')"
        FAMILY="fedora-26-64"
        DESCRIPTION="Base Fedora 26 64 bits"
        DISK="$(hostname)"
        ;;
    fedora-27-64-base)
        IMAGE="fedora-27-64-base-v$(date +'%Y%m%d')"
        FAMILY="fedora-27-64-base"
        DESCRIPTION="Base image"
        DISK="$(hostname)"
        ;;
    fedora-27-64)
        IMAGE="fedora-27-64-v$(date +'%Y%m%d')"
        FAMILY="fedora-27-64"
        DESCRIPTION="Fedora 27 64 bits with SELinux permissive and test dependencies"
        DISK="$(hostname)"
        ;;
    fedora-28-64-base)
        IMAGE="fedora-28-64-base-v$(date +'%Y%m%d')"
        FAMILY="fedora-28-64-base"
        DESCRIPTION="Base image"
        DISK="$(hostname)"
        ;;
    fedora-28-64)
        IMAGE="fedora-28-64-v$(date +'%Y%m%d')"
        FAMILY="fedora-28-64"
        DESCRIPTION="Fedora 28 64 bits with test dependencies"
        DISK="$(hostname)"
        ;;
    # Arch Linux
    arch-linux-64-base)
        IMAGE="arch-linux-64-base-v$(date +'%Y%m%d')"
        FAMILY="arch-linux-64-base"
        DESCRIPTION="Base image"
        DISK="$(dhcpcd -T | sed -n 's/new_host_name=\(.*\).c.computeengine.internal/\1/gp')"
        ;;
    arch-linux-64)
        IMAGE="arch-linux-64-v$(date +'%Y%m%d')"
        FAMILY="arch-linux-64"
        DESCRIPTION="Arch Linux 64 bits with test dependencies"
        DISK="$(dhcpcd -T | sed -n 's/new_host_name=\(.*\).c.computeengine.internal/\1/gp')"
        ;;
    # Opensuse
    opensuse-42.2-64-base)
        IMAGE="opensuse-leap-42-2-64-base-v$(date +'%Y%m%d')"
        FAMILY="opensuse-leap-42-2-64-base"
        DESCRIPTION="Base image"
        DISK="$(hostname)"
        ;;
    opensuse-42.2-64)
        IMAGE="opensuse-leap-42-2-64-v$(date +'%Y%m%d')"
        FAMILY="opensuse-leap-42-2-64"
        DESCRIPTION="Opensuse leap 42.2 64 bits with test dependencies"
        DISK="$(hostname)"
        ;;
    opensuse-42.3-64)
        IMAGE="opensuse-leap-42-3-64-v$(date +'%Y%m%d')"
        FAMILY="opensuse-leap-42-3-64"
        DESCRIPTION="Opensuse leap 42.3 64 bits"
        DISK="$(hostname)"
        ;;
    # Amazon linux 2
    amazon-linux-2-64-base)
        IMAGE="amazon-linux-2-64-base-v$(date +'%Y%m%d')"
        FAMILY="amazon-linux-2-64-base"
        DESCRIPTION="Base image"
        DISK="$(hostname)"
        ;;
    amazon-linux-2-64)
        IMAGE="amazon-linux-2-64-v$(date +'%Y%m%d')"
        FAMILY="amazon-linux-2-64"
        DESCRIPTION="Amazon Linux 2 64 bits"
        DISK="$(hostname)"
        ;;
    *)
        echo "ERROR: Unsupported distribution '$SPREAD_SYSTEM'"
        exit 1
        ;;
esac


export IMAGE
export FAMILY
export DESCRIPTION
export DISK