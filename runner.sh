#!/bin/bash

set -x

PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
CURRENT_DIR="$(pwd)"

GCE_PROJECT=computeengine
ZONE=us-east1-b
BUCKET_NAME=spread-images

run_task_google() {
    local task=$1
    get_systems_for_task_google "$task"

    cd "$PROJECT_DIR"
    if ! spread "google:$SOURCE_SYSTEM:tasks/google/$task"; then
        echo "image task failed"
        return
    fi
    
    if [ "$RUN_SNAPD" = "true" ]; then
        echo "running snapd test suite on target system: $TARGET_SYSTEM"
        if ! run_snapd_tests google "$TARGET_SYSTEM"; then
            echo "snapd tests failed, reverting image"
            . "$PROJECT_DIR/lib/names.sh"
            . "$PROJECT_DIR/lib/google.sh"
            images_available="$(number_of_images_from_family "$FAMILY")"
            if [ "$images_available" -gt 1 ]; then
                echo "deleting latest image for family $FAMILY"
                delete_latest_image_from_family "$FAMILY"
            else
                echo "skiping image deletion due to there is just 1 image available"
            fi
        else
            echo "snapd test suite passed, image is ready"
        fi
    fi
}

run_snapd_tests() {
    local backend=$1
    local system=$2

    cd "$CURRENT_DIR"
    echo "running on dir: $CURRENT_DIR"

    if [ ! -d "$CURRENT_DIR/snapd" ]; then
        echo "Downloading snapd..."
        git clone https://github.com/snapcore/snapd.git snapd
        cd "$CURRENT_DIR/snapd"
    else
        cd "$CURRENT_DIR/snapd" && git fetch origin && git pull
    fi

    spread "${backend}:${system}"
    cd "$CURRENT_DIR"
}

get_systems_for_task_google() {
    local task=$1    
    case "$task" in
        add-amazon-linux-2)
            SOURCE_SYSTEM=ubuntu-16.04-64-base
            TARGET_SYSTEM=amazon-linux-2-64
            RUN_SNAPD=false
            ;;
        add-arch-linux)
            SOURCE_SYSTEM=ubuntu-16.04-64-base
            TARGET_SYSTEM=arch-linux-64-base
            RUN_SNAPD=false
            ;;
        add-debian-sid)
            SOURCE_SYSTEM=debian-9-64-base
            TARGET_SYSTEM=debian-sid-base
            RUN_SNAPD=false
            ;;
        add-fedora-26-64)
            # First added manually using a local fedora vm
            SOURCE_SYSTEM=fedora-26-64
            TARGET_SYSTEM=fedora-26-64
            RUN_SNAPD=false
            ;;
        add-fedora-27-64)
            # First added manually using a local fedora vm
            SOURCE_SYSTEM=fedora-26-64
            TARGET_SYSTEM=fedora-27-64-base
            RUN_SNAPD=false
            ;;
        add-fedora-28-64)
            SOURCE_SYSTEM=fedora-27-64
            TARGET_SYSTEM=fedora-28-64-base
            RUN_SNAPD=false
            ;;
        add-opensuse-42-2-64)
            SOURCE_SYSTEM=ubuntu-16.04-64-base
            TARGET_SYSTEM=opensuse-42.2-64-base
            RUN_SNAPD=false
            ;;
        add-ubuntu-16.04-32)
            SOURCE_SYSTEM=ubuntu-16.04-64-base
            TARGET_SYSTEM=ubuntu-16.04-32-base
            RUN_SNAPD=false
            ;;
        update-amazon-linux-2)
            SOURCE_SYSTEM=amazon-linux-2-64-base
            TARGET_SYSTEM=amazon-linux-2-64
            RUN_SNAPD=false
            ;;
        update-arch-linux)
            SOURCE_SYSTEM=arch-linux-64-base
            TARGET_SYSTEM=arch-linux-64
            RUN_SNAPD=true
            ;;
        update-debian-9)
            SOURCE_SYSTEM=debian-9-64-base
            TARGET_SYSTEM=debian-9-64
            RUN_SNAPD=true
            ;;
        update-debian-sid)
            SOURCE_SYSTEM=debian-sid-64-base
            TARGET_SYSTEM=debian-sid-64
            RUN_SNAPD=true
            ;;
        update-fedora-27-64)
            SOURCE_SYSTEM=fedora-27-64-base
            TARGET_SYSTEM=fedora-27-64
            RUN_SNAPD=true
            ;;
        update-fedora-28-64)
            SOURCE_SYSTEM=fedora-28-64-base
            TARGET_SYSTEM=fedora-28-64
            RUN_SNAPD=true
            ;;
        update-opensuse-42-3)
            SOURCE_SYSTEM=opensuse-42.3-64-base
            TARGET_SYSTEM=opensuse-42.3-64
            RUN_SNAPD=true
            ;;
        update-ubuntu-14.04-64)
            SOURCE_SYSTEM=ubuntu-14.04-64-base
            TARGET_SYSTEM=ubuntu-14.04-64
            RUN_SNAPD=true
            ;;
        update-ubuntu-16.04-32)
            SOURCE_SYSTEM=ubuntu-16.04-32-base
            TARGET_SYSTEM=ubuntu-16.04-32
            RUN_SNAPD=true
            ;;
        update-ubuntu-16.04-64)
            SOURCE_SYSTEM=ubuntu-16.04-64-base
            TARGET_SYSTEM=ubuntu-16.04-64
            RUN_SNAPD=true
            ;;
        update-ubuntu-18.04-64)
            SOURCE_SYSTEM=ubuntu-18.04-64-base
            TARGET_SYSTEM=ubuntu-18.04-64
            RUN_SNAPD=true
            ;;            
        *)
            echo "ERROR: Unsupported distribution '$SPREAD_SYSTEM'"
            exit 1
            ;;
    esac

    export SOURCE_SYSTEM
    export TARGET_SYSTEM
    export RUN_SNAPD
}
