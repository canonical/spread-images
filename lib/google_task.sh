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
            ;;
        arch-linux)
            SOURCE_SYSTEM=ubuntu-16.04-64
            TARGET_SYSTEM=arch-linux-64-base
            RUN_SNAPD=false
            ;;
        debian-sid)
            SOURCE_SYSTEM=debian-9-64-base
            TARGET_SYSTEM=debian-sid-base
            RUN_SNAPD=false
            ;;
        fedora-27-64)
            # First added manually using a local fedora vm
            SOURCE_SYSTEM=fedora-26-64
            TARGET_SYSTEM=fedora-27-64-base
            RUN_SNAPD=false
            ;;
        fedora-28-64)
            SOURCE_SYSTEM=fedora-27-64
            TARGET_SYSTEM=fedora-28-64-base
            RUN_SNAPD=false
            ;;
        fedora-29-64)
            SOURCE_SYSTEM=fedora-28-64
            TARGET_SYSTEM=fedora-29-64-base
            RUN_SNAPD=false
            ;;
        fedora-30-64)
            SOURCE_SYSTEM=fedora-29-64
            TARGET_SYSTEM=fedora-30-64-base
            RUN_SNAPD=false
            ;;
        fedora-31-64)
            SOURCE_SYSTEM=fedora-30-64
            TARGET_SYSTEM=fedora-31-64-base
            RUN_SNAPD=false
            ;;
        opensuse-42-2-64)
            SOURCE_SYSTEM=ubuntu-16.04-64
            TARGET_SYSTEM=opensuse-42.2-64-base
            RUN_SNAPD=false
            ;;
        ubuntu-16.04-32)
            SOURCE_SYSTEM=ubuntu-16.04-64
            TARGET_SYSTEM=ubuntu-16.04-32-base
            RUN_SNAPD=false
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
            RUN_SNAPD=true
            ;;
        arch-linux)
            SOURCE_SYSTEM=arch-linux-64-base
            TARGET_SYSTEM=arch-linux-64
            RUN_SNAPD=true
            ;;
        centos-7)
            SOURCE_SYSTEM=centos-7-64-base
            TARGET_SYSTEM=centos-7-64
            RUN_SNAPD=true
            ;;
        centos-8)
            SOURCE_SYSTEM=centos-8-64-base
            TARGET_SYSTEM=centos-8-64
            RUN_SNAPD=true
            ;;
        debian-9)
            SOURCE_SYSTEM=debian-9-64-base
            TARGET_SYSTEM=debian-9-64
            RUN_SNAPD=true
            ;;
        debian-sid)
            SOURCE_SYSTEM=debian-sid-64-base
            TARGET_SYSTEM=debian-sid-64
            RUN_SNAPD=false
            ;;
        fedora-31-64)
            SOURCE_SYSTEM=fedora-31-64-base
            TARGET_SYSTEM=fedora-31-64
            RUN_SNAPD=true
            ;;
        fedora-32-64)
            SOURCE_SYSTEM=fedora-32-64-base
            TARGET_SYSTEM=fedora-32-64
            RUN_SNAPD=true
            ;;
        fedora-33-64)
            SOURCE_SYSTEM=fedora-33-64-base
            TARGET_SYSTEM=fedora-33-64
            RUN_SNAPD=true
            ;;
        fedora-rawhide-64)
            SOURCE_SYSTEM=fedora-rawhide-64
            TARGET_SYSTEM=fedora-rawhide-64
            RUN_SNAPD=false
            ;;
        opensuse-15-1)
            SOURCE_SYSTEM=opensuse-15.1-64-base
            TARGET_SYSTEM=opensuse-15.1-64
            RUN_SNAPD=true
            ;;
        opensuse-15-2)
            SOURCE_SYSTEM=opensuse-15.2-64-base
            TARGET_SYSTEM=opensuse-15.2-64
            RUN_SNAPD=true
            ;;
        opensuse-tumbleweed)
            SOURCE_SYSTEM=opensuse-tumbleweed-64-base
            TARGET_SYSTEM=opensuse-tumbleweed-64
            RUN_SNAPD=true
            ;;
        opensuse-tumbleweed-2)
            SOURCE_SYSTEM=opensuse-tumbleweed-2-64-base
            TARGET_SYSTEM=opensuse-tumbleweed-2-64
            RUN_SNAPD=true
            ;;
        ubuntu-14.04-64)
            SOURCE_SYSTEM=ubuntu-14.04-64
            TARGET_SYSTEM=ubuntu-14.04-64
            RUN_SNAPD=true
            ;;
        ubuntu-16.04-32)
            SOURCE_SYSTEM=ubuntu-16.04-32-base
            TARGET_SYSTEM=ubuntu-16.04-32
            RUN_SNAPD=true
            ;;
        ubuntu-16.04-64)
            SOURCE_SYSTEM=ubuntu-16.04-64-base
            TARGET_SYSTEM=ubuntu-16.04-64
            RUN_SNAPD=true
            ;;
        ubuntu-18.04-64)
            SOURCE_SYSTEM=ubuntu-18.04-64-base
            TARGET_SYSTEM=ubuntu-18.04-64
            RUN_SNAPD=true
            ;;            
        ubuntu-20.04-64)
            SOURCE_SYSTEM=ubuntu-20.04-64-base
            TARGET_SYSTEM=ubuntu-20.04-64
            RUN_SNAPD=true
            ;;
        ubuntu-21.04-64)
            SOURCE_SYSTEM=ubuntu-21.04-64-base
            TARGET_SYSTEM=ubuntu-21.04-64
            RUN_SNAPD=true
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
