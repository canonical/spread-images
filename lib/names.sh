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
        ubuntu-16.04-64-virt-enabled)
            IMAGE="ubuntu-1604-64-v$(date +'%Y%m%d')-virt-enabled"
            FAMILY="ubuntu-1604-64-virt-enabled"
            DESCRIPTION="Image with virtualization enabled"
            ;;
        ubuntu-18.04-32-base)
            IMAGE="ubuntu-1804-32-base-v$(date +'%Y%m%d')"
            FAMILY="ubuntu-1804-32-base"
            DESCRIPTION="Base image"
            ;;
        ubuntu-18.04-32)
            IMAGE="ubuntu-1804-32-v$(date +'%Y%m%d')"
            FAMILY="ubuntu-1804-32"
            DESCRIPTION="Ubuntu 18.04 32 bits"
            ;;
        ubuntu-18.04-64)
            IMAGE="ubuntu-1804-64-v$(date +'%Y%m%d')"
            FAMILY="ubuntu-1804-64"
            DESCRIPTION="Ubuntu 18.04 64 bits"
            ;;
        ubuntu-18.04-64-virt-enabled)
            IMAGE="ubuntu-1804-64-v$(date +'%Y%m%d')-virt-enabled"
            FAMILY="ubuntu-1804-64-virt-enabled"
            DESCRIPTION="Image with virtualization enabled"
            ;;
        ubuntu-20.04-64)
            IMAGE="ubuntu-2004-64-v$(date +'%Y%m%d')"
            FAMILY="ubuntu-2004-64"
            DESCRIPTION="Ubuntu 20.04 64 bits"
            ;;
        ubuntu-20.04-64-virt-enabled)
            IMAGE="ubuntu-2004-64-v$(date +'%Y%m%d')-virt-enabled"
            FAMILY="ubuntu-2004-64-virt-enabled"
            DESCRIPTION="Image with virtualization enabled"
            ;;
        ubuntu-20.04-arm-64)
            IMAGE="ubuntu-2004-arm-64-v$(date +'%Y%m%d')"
            FAMILY="ubuntu-2004-arm-64"
            DESCRIPTION="Ubuntu 20.04 ARM 64 bits"
            ;;
        ubuntu-20.04-arm-64-virt-enabled)
            IMAGE="ubuntu-2004-arm-64-v$(date +'%Y%m%d')-virt-enabled"
            FAMILY="ubuntu-2004-arm-64-virt-enabled"
            DESCRIPTION="Image with virtualization enabled"
            ;;
        ubuntu-22.04-64)
            IMAGE="ubuntu-2204-64-v$(date +'%Y%m%d')"
            FAMILY="ubuntu-2204-64"
            DESCRIPTION="Ubuntu 22.04 64 bits"
            ;;
        ubuntu-22.04-64-virt-enabled)
            IMAGE="ubuntu-2204-64-v$(date +'%Y%m%d')-virt-enabled"
            FAMILY="ubuntu-2204-64-virt-enabled"
            DESCRIPTION="Image with virtualization enabled"
            ;;
        ubuntu-22.10-64)
            IMAGE="ubuntu-2210-64-v$(date +'%Y%m%d')"
            FAMILY="ubuntu-2210-64"
            DESCRIPTION="Ubuntu 22.10 64 bits"
            ;;

        # Debian
       debian-10-64-base)
            IMAGE="debian-10-64-base-v$(date +'%Y%m%d')"
            FAMILY="debian-10-64-base"
            DESCRIPTION="Base image"
            ;;
        debian-10-64)
            IMAGE="debian-10-64-v$(date +'%Y%m%d')"
            FAMILY="debian-10-64"
            DESCRIPTION="Debian 10 64 bits"
            ;;
       debian-11-64-base)
            IMAGE="debian-11-64-base-v$(date +'%Y%m%d')"
            FAMILY="debian-11-64-base"
            DESCRIPTION="Base image"
            ;;
        debian-11-64)
            IMAGE="debian-11-64-v$(date +'%Y%m%d')"
            FAMILY="debian-11-64"
            DESCRIPTION="Debian 11 64 bits"
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
        fedora-33-64-base)
            IMAGE="fedora-33-64-base-v$(date +'%Y%m%d')"
            FAMILY="fedora-33-64-base"
            DESCRIPTION="Base image"
            ;;
        fedora-33-64)
            IMAGE="fedora-33-64-v$(date +'%Y%m%d')"
            FAMILY="fedora-33-64"
            DESCRIPTION="Fedora 33 64 bits with test dependencies"
            ;;
        fedora-34-64-base)
            IMAGE="fedora-34-64-base-v$(date +'%Y%m%d')"
            FAMILY="fedora-34-64-base"
            DESCRIPTION="Base image"
            ;;
        fedora-34-64)
            IMAGE="fedora-34-64-v$(date +'%Y%m%d')"
            FAMILY="fedora-34-64"
            DESCRIPTION="Fedora 34 64 bits with test dependencies"
            ;;
        fedora-35-64-base)
            IMAGE="fedora-35-64-base-v$(date +'%Y%m%d')"
            FAMILY="fedora-35-64-base"
            DESCRIPTION="Base image"
            ;;
        fedora-35-64)
            IMAGE="fedora-35-64-v$(date +'%Y%m%d')"
            FAMILY="fedora-35-64"
            DESCRIPTION="Fedora 35 64 bits with test dependencies"
            ;;
        fedora-36-64-base)
            IMAGE="fedora-36-64-base-v$(date +'%Y%m%d')"
            FAMILY="fedora-36-64-base"
            DESCRIPTION="Base image"
            ;;
        fedora-36-64)
            IMAGE="fedora-36-64-v$(date +'%Y%m%d')"
            FAMILY="fedora-36-64"
            DESCRIPTION="Fedora 36 64 bits with test dependencies"
            ;;
        fedora-rawhide-64)
            IMAGE="fedora-rawhide-64-v$(date +'%Y%m%d')"
            FAMILY="fedora-rawhide-64"
            DESCRIPTION="Fedora rawhide 64 bits"
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
        opensuse-15.2-64-base)
            IMAGE="opensuse-leap-15-2-64-base-v$(date +'%Y%m%d')"
            FAMILY="opensuse-leap-15-2-64-base"
            DESCRIPTION="Base image"
            ;;
        opensuse-15.2-64)
            IMAGE="opensuse-leap-15-2-64-v$(date +'%Y%m%d')"
            FAMILY="opensuse-leap-15-2-64"
            DESCRIPTION="Opensuse leap 15.2 64 bits with test dependencies"
            ;;
        opensuse-15.3-64-base)
            IMAGE="opensuse-leap-15-3-64-base-v$(date +'%Y%m%d')"
            FAMILY="opensuse-leap-15-3-64-base"
            DESCRIPTION="Base image"
            ;;
        opensuse-15.3-64)
            IMAGE="opensuse-leap-15-3-64-v$(date +'%Y%m%d')"
            FAMILY="opensuse-leap-15-3-64"
            DESCRIPTION="Opensuse leap 15.3 64 bits with test dependencies"
            ;;
        opensuse-15.4-64-base)
            IMAGE="opensuse-leap-15-4-64-base-v$(date +'%Y%m%d')"
            FAMILY="opensuse-leap-15-4-64-base"
            DESCRIPTION="Base image"
            ;;
        opensuse-15.4-64)
            IMAGE="opensuse-leap-15-4-64-v$(date +'%Y%m%d')"
            FAMILY="opensuse-leap-15-4-64"
            DESCRIPTION="Opensuse leap 15.4 64 bits with test dependencies"
            ;;
        opensuse-tumbleweed-64-base)
            IMAGE="opensuse-tumbleweed-64-base-v$(date +'%Y%m%d')"
            FAMILY="opensuse-tumbleweed-64-base"
            DESCRIPTION="Base image"
            ;;
        opensuse-tumbleweed-64)
            IMAGE="opensuse-tumbleweed-64-v$(date +'%Y%m%d')"
            FAMILY="opensuse-tumbleweed-64"
            DESCRIPTION="Opensuse tumbleweed 64 bits"
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
        # Centos 7
        centos-7-64-base)
            IMAGE="centos-7-64-base-v$(date +'%Y%m%d')"
            FAMILY="centos-7-64-base"
            DESCRIPTION="Base image"
            ;;
        centos-7-64)
            IMAGE="centos-7-64-v$(date +'%Y%m%d')"
            FAMILY="centos-7-64"
            DESCRIPTION="Centos 7 64 bits"
            ;;
        # Centos 8
        centos-8-64-base)
            IMAGE="centos-8-64-base-v$(date +'%Y%m%d')"
            FAMILY="centos-8-64-base"
            DESCRIPTION="Base image"
            ;;
        centos-8-64)
            IMAGE="centos-8-64-v$(date +'%Y%m%d')"
            FAMILY="centos-8-64"
            DESCRIPTION="Centos 8 64 bits"
            ;;
        # Centos 9
        centos-9-64-base)
            IMAGE="centos-9-64-base-v$(date +'%Y%m%d')"
            FAMILY="centos-9-64-base"
            DESCRIPTION="Base image"
            ;;
        centos-9-64)
            IMAGE="centos-9-64-v$(date +'%Y%m%d')"
            FAMILY="centos-9-64"
            DESCRIPTION="Centos 9 64 bits"
            ;;
        *)
            echo "ERROR: Unsupported distribution '$TARGET_SYSTEM'"
            exit 1
            ;;
    esac
fi

DISK="$(curl http://metadata.google.internal/computeMetadata/v1/instance/hostname -H Metadata-Flavor:Google | cut -d . -f1)"

export IMAGE
export FAMILY
export DESCRIPTION
export DISK
