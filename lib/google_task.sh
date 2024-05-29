#!/bin/bash
set -x

if [ -z "$GOOGLE_TASK" ]; then
    echo "ERROR: GOOGLE_TASK variable not set"
    exit 1
fi
if [ -z "$GOOGLE_ACTION" ]; then
    echo "ERROR: GOOGLE_ACTION variable not set"
    exit 1
fi

if [ "$GOOGLE_ACTION" = "add-image" ]; then
    case "$GOOGLE_TASK" in
        amazon-linux-2)
            SOURCE_SYSTEM=ubuntu-16.04-64
            TARGET_SYSTEM=amazon-linux-2-64
            RUN_SNAPD=false
            BACKUPS=0
            ;;
        arch-linux)
            SOURCE_SYSTEM=ubuntu-16.04-64
            TARGET_SYSTEM=arch-linux-64-base
            RUN_SNAPD=false
            BACKUPS=0
            ;;
        debian-sid)
            SOURCE_SYSTEM=debian-9-64-base
            TARGET_SYSTEM=debian-sid-base
            RUN_SNAPD=false
            BACKUPS=0
            ;;
        ubuntu-16.04-32)
            SOURCE_SYSTEM=ubuntu-16.04-64
            TARGET_SYSTEM=ubuntu-16.04-32-base
            RUN_SNAPD=false
            BACKUPS=0
            ;;
        *)
        echo "ERROR: Unsupported distribution $SPREAD_SYSTEM"
        exit 1
        ;;
    esac
elif [ "$GOOGLE_ACTION" = "update-image" ]; then
    case "$GOOGLE_TASK" in
        amazon-linux-2)
            SOURCE_SYSTEM=amazon-linux-2-64-base
            TARGET_SYSTEM=amazon-linux-2-64
            RUN_SNAPD=false
            BACKUPS=0
            ;;
        amazon-linux-2023)
            SOURCE_SYSTEM=amazon-linux-2023-64-base
            TARGET_SYSTEM=amazon-linux-2023-64
            RUN_SNAPD=false
            BACKUPS=0
            ;;
        arch-linux)
            SOURCE_SYSTEM=arch-linux-64-base
            TARGET_SYSTEM=arch-linux-64
            RUN_SNAPD=false
            BACKUPS=0
            ;;
        centos-7)
            SOURCE_SYSTEM=centos-7-64-base
            TARGET_SYSTEM=centos-7-64
            RUN_SNAPD=false
            BACKUPS=0
            ;;
        centos-8)
            SOURCE_SYSTEM=centos-8-64-base
            TARGET_SYSTEM=centos-8-64
            RUN_SNAPD=false
            BACKUPS=0
            ;;
        centos-9)
            SOURCE_SYSTEM=centos-9-64-base
            TARGET_SYSTEM=centos-9-64
            RUN_SNAPD=false
            BACKUPS=0
            ;;
        debian-11)
            SOURCE_SYSTEM=debian-11-64-base
            TARGET_SYSTEM=debian-11-64
            RUN_SNAPD=false
            BACKUPS=0
            ;;
        debian-12)
            SOURCE_SYSTEM=debian-12-64-base
            TARGET_SYSTEM=debian-12-64
            RUN_SNAPD=false
            BACKUPS=0
            ;;
        debian-sid)
            SOURCE_SYSTEM=debian-sid-64-base
            TARGET_SYSTEM=debian-sid-64
            RUN_SNAPD=false
            BACKUPS=0
            ;;
        fedora-38-64)
            SOURCE_SYSTEM=fedora-38-64-base
            TARGET_SYSTEM=fedora-38-64
            RUN_SNAPD=false
            BACKUPS=0
            ;;
        fedora-39-64)
            SOURCE_SYSTEM=fedora-39-64-base
            TARGET_SYSTEM=fedora-39-64
            RUN_SNAPD=false
            BACKUPS=0
            ;;
        opensuse-15-5)
            SOURCE_SYSTEM=opensuse-15.5-64-base
            TARGET_SYSTEM=opensuse-15.5-64
            RUN_SNAPD=false
            BACKUPS=0
            ;;
        opensuse-tumbleweed)
            SOURCE_SYSTEM=opensuse-tumbleweed-64-base
            TARGET_SYSTEM=opensuse-tumbleweed-64
            RUN_SNAPD=false
            BACKUPS=0
            ;;
        ubuntu-14.04-64)
            SOURCE_SYSTEM=ubuntu-14.04-64
            TARGET_SYSTEM=ubuntu-14.04-64
            RUN_SNAPD=false
            BACKUPS=1
            ;;
        ubuntu-16.04-64)
            SOURCE_SYSTEM=ubuntu-16.04-64
            TARGET_SYSTEM=ubuntu-16.04-64
            RUN_SNAPD=false
            BACKUPS=1
            ;;
        ubuntu-18.04-32)
            SOURCE_SYSTEM=ubuntu-18.04-32-base
            TARGET_SYSTEM=ubuntu-18.04-32
            RUN_SNAPD=false
            BACKUPS=1
            ;;
        ubuntu-18.04-64)
            SOURCE_SYSTEM=ubuntu-18.04-64
            TARGET_SYSTEM=ubuntu-18.04-64
            RUN_SNAPD=false
            BACKUPS=0
            ;;            
        ubuntu-20.04-64)
            SOURCE_SYSTEM=ubuntu-20.04-64-base
            TARGET_SYSTEM=ubuntu-20.04-64
            RUN_SNAPD=false
            BACKUPS=0
            ;;
        ubuntu-22.04-64)
            SOURCE_SYSTEM=ubuntu-22.04-64-base
            TARGET_SYSTEM=ubuntu-22.04-64
            RUN_SNAPD=false
            BACKUPS=0
            ;;
        ubuntu-23.10-64)
            SOURCE_SYSTEM=ubuntu-23.10-64-base
            TARGET_SYSTEM=ubuntu-23.10-64
            RUN_SNAPD=false
            BACKUPS=0
            ;;
        ubuntu-24.04-64)
            SOURCE_SYSTEM=ubuntu-24.04-64-base
            TARGET_SYSTEM=ubuntu-24.04-64
            RUN_SNAPD=false
            BACKUPS=0
            ;;
        ubuntu-24.10-64)
            SOURCE_SYSTEM=ubuntu-24.10-64-base
            TARGET_SYSTEM=ubuntu-24.10-64
            RUN_SNAPD=false
            BACKUPS=0
            ;;
        *)
            echo "ERROR: Unsupported distribution $SPREAD_SYSTEM"
            exit 1
            ;;
    esac
else
    echo "ERROR: google action $GOOGLE_ACTION"
    exit 1
fi
