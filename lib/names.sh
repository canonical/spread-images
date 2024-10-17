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
        ubuntu-20.04-64-pro-fips-enabled)
            IMAGE="ubuntu-2004-64-v$(date +'%Y%m%d')-pro-fips-enabled"
            FAMILY="ubuntu-2004-64-pro-fips-enabled"
            DESCRIPTION="Image with fips enabled"
            ;;
        ubuntu-22.04-64)
            IMAGE="ubuntu-2204-64-v$(date +'%Y%m%d')"
            FAMILY="ubuntu-2204-64"
            DESCRIPTION="Ubuntu 22.04 64 bits"
            ;;
        ubuntu-22.04-64-devstack)
            IMAGE="ubuntu-jammy-devstack-v$(date +'%Y%m%d')"
            FAMILY="ubuntu-jammy-devstack"
            DESCRIPTION="Ubuntu 22.04 64 bits with devstack installed"
            ;;
        ubuntu-22.04-64-virt-enabled)
            IMAGE="ubuntu-2204-64-v$(date +'%Y%m%d')-virt-enabled"
            FAMILY="ubuntu-2204-64-virt-enabled"
            DESCRIPTION="Image with virtualization enabled"
            ;;
        ubuntu-22.04-64-pro-fips-enabled)
            IMAGE="ubuntu-2204-64-v$(date +'%Y%m%d')-pro-fips-enabled"
            FAMILY="ubuntu-2204-64-pro-fips-enabled"
            DESCRIPTION="Image with fips enabled"
            ;;
        ubuntu-22.04-arm-64)
            IMAGE="ubuntu-2204-arm-64-v$(date +'%Y%m%d')"
            FAMILY="ubuntu-2204-arm-64"
            DESCRIPTION="Ubuntu 22.04 ARM 64 bits"
            ;;
        ubuntu-22.04-arm-64-virt-enabled)
            IMAGE="ubuntu-2204-arm-64-v$(date +'%Y%m%d')-virt-enabled"
            FAMILY="ubuntu-2204-arm-64-virt-enabled"
            DESCRIPTION="Image with virtualization enabled"
            ;;
        ubuntu-24.04-64)
            IMAGE="ubuntu-2404-64-v$(date +'%Y%m%d')"
            FAMILY="ubuntu-2404-64"
            DESCRIPTION="Ubuntu 24.04 64 bits"
            ;;
        ubuntu-24.04-64-virt-enabled)
            IMAGE="ubuntu-2404-64-v$(date +'%Y%m%d')-virt-enabled"
            FAMILY="ubuntu-2404-64-virt-enabled"
            DESCRIPTION="Image with virtualization enabled"
            ;;
        ubuntu-24.10-64)
            IMAGE="ubuntu-2410-64-v$(date +'%Y%m%d')"
            FAMILY="ubuntu-2410-64"
            DESCRIPTION="Ubuntu 24.10 64 bits"
            ;;
        # Debian
        debian-11-64)
            IMAGE="debian-11-64-v$(date +'%Y%m%d')"
            FAMILY="debian-11-64"
            DESCRIPTION="Debian 11 64 bits"
            ;;
        debian-12-64)
            IMAGE="debian-12-64-v$(date +'%Y%m%d')"
            FAMILY="debian-12-64"
            DESCRIPTION="Debian 12 64 bits"
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
        fedora-39-64)
            IMAGE="fedora-39-64-v$(date +'%Y%m%d')"
            FAMILY="fedora-39-64"
            DESCRIPTION="Fedora 39 64 bits with test dependencies"
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
        opensuse-15.5-64)
            IMAGE="opensuse-leap-15-5-64-v$(date +'%Y%m%d')"
            FAMILY="opensuse-leap-15-5-64"
            DESCRIPTION="Opensuse leap 15.5 64 bits with test dependencies"
            ;;
        opensuse-15.6-64)
            IMAGE="opensuse-leap-15-6-64-v$(date +'%Y%m%d')"
            FAMILY="opensuse-leap-15-6-64"
            DESCRIPTION="Opensuse leap 15.6 64 bits with test dependencies"
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
        # Amazon linux 2023
        amazon-linux-2023-64-base)
            IMAGE="amazon-linux-2023-64-base-v$(date +'%Y%m%d')"
            FAMILY="amazon-linux-2023-64-base"
            DESCRIPTION="Base image"
            ;;
        amazon-linux-2023-64)
            IMAGE="amazon-linux-2023-64-v$(date +'%Y%m%d')"
            FAMILY="amazon-linux-2023-64"
            DESCRIPTION="Amazon Linux 2023 64 bits"
            ;;
        # Centos 9
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
# when it failed to retrieve the metadate, try using the metadata ip instead
if [ -z "$DISK" ]; then
    DISK="$(curl http://169.254.169.254/computeMetadata/v1/instance/hostname -H Metadata-Flavor:Google | cut -d . -f1)"
fi

export IMAGE
export FAMILY
export DESCRIPTION
export DISK
