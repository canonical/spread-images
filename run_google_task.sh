#!/bin/bash

set -x

PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
CURRENT_DIR="$(pwd)"
TMP_IMAGE_ID="$RANDOM"
SNAPD_DIR=${SNAPD_DIR:-snapd}

GCE_PROJECT=computeengine
ZONE=us-east1-b
BUCKET_NAME=spread-images

TASK=$1

run_task_google() {
    local task=$1
    
    get_spread
    get_env_for_task_google "$task"

    if ! run_spread_images_task google "$SOURCE_SYSTEM" "$task" "$RUN_SNAPD"; then
        echo "image task failed"
        exit 1
    fi

    if [ "$RUN_SNAPD" = "true" ]; then
        echo "running snapd test suite on target system: $TARGET_SYSTEM"

        . "$PROJECT_DIR/lib/google.sh"
        . "$PROJECT_DIR/lib/names.sh"
        local tmp_image="$IMAGE"
        local tmp_family="$FAMILY"
        if run_snapd_tests google "$TARGET_SYSTEM" "$tmp_image"; then
            echo "snapd test suite passed, clonning tmp image"
            TMP_IMAGE_ID= . "$PROJECT_DIR/lib/names.sh"
            local final_image="$IMAGE"
            local final_family="$FAMILY"
            local final_description="$DESCRIPTION"
            create_image_from_image "$final_image" "$final_family" "$final_description" "$tmp_image"
            echo "deleting tmp image"
            delete_image "$tmp_image" "$tmp_family"
        else
            echo "Snapd tests failed, deleting tmp image and exiting..."
            delete_image "$tmp_image" "$tmp_family"
            exit 1
        fi
    else
        echo "snapd tests not executed on this image, image is ready"
    fi
}

run_spread_images_task() {
    local backend=$1
    local system=$2
    local task=$3
    local run_snapd=$4

    if [ ! -d "${PROJECT_DIR}/tasks/${backend}/${task}" ]; then
        echo "task $task does not exist on spread-images project for backend $backend"
        return 1
    fi
    if [ "$run_snapd" = "true" ]; then
        echo "Running spread-imags task and creating tmp image"
        ( cd "$PROJECT_DIR" && SPREAD_TMP_IMAGE_ID="$TMP_IMAGE_ID" spread "${backend}:${system}:tasks/${backend}/${task}" )
    else
        echo "Running spread-imags task and creating final image"
        ( cd "$PROJECT_DIR" && spread "${backend}:${system}:tasks/${backend}/${task}" )
    fi
    return $?
}

run_snapd_tests() {
    local backend=$1
    local system=$2
    local image=$3

    echo "running on dir: $CURRENT_DIR"

    if [ ! -d "$CURRENT_DIR/$SNAPD_DIR" ]; then
        echo "Downloading snapd..."
        ( cd "$CURRENT_DIR" && git clone https://github.com/snapcore/snapd.git "$SNAPD_DIR" )
    else
        echo "Updating snapd..."
        ( cd "$CURRENT_DIR/$SNAPD_DIR" && git checkout -- spread.yaml && git fetch origin && git pull )
    fi

    echo "Configuring target image"
    python3 "$PROJECT_DIR/update_image.py" "$CURRENT_DIR/$SNAPD_DIR/spread.yaml" "$backend" "$system" "$image"    

    ( cd "$CURRENT_DIR/$SNAPD_DIR" && spread "${backend}:${system}" )
    return $?
}

get_spread() {
    echo "Getting spread"

    export SPREAD_DIR=$CURRENT_DIR/spread
    export PATH=$SPREAD_DIR:$PATH

    if [ -f "$SPREAD_DIR/spread" ]; then
        echo "Spread already downloaded and ready to use"
    else
        mkdir -p "$SPREAD_DIR"
        ( cd "$SPREAD_DIR" && curl -s -O https://niemeyer.s3.amazonaws.com/spread-amd64.tar.gz && tar xzvf spread-amd64.tar.gz ) 
        echo "Spread downloaded and ready to use"
    fi
}

get_env_for_task_google() {
    local task=$1    
    case "$task" in
        add-amazon-linux-2)
            SOURCE_SYSTEM=ubuntu-16.04-64
            TARGET_SYSTEM=amazon-linux-2-64
            RUN_SNAPD=false
            ;;
        add-arch-linux)
            SOURCE_SYSTEM=ubuntu-16.04-64
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
            SOURCE_SYSTEM=ubuntu-16.04-64
            TARGET_SYSTEM=opensuse-42.2-64-base
            RUN_SNAPD=false
            ;;
        add-ubuntu-16.04-32)
            SOURCE_SYSTEM=ubuntu-16.04-64
            TARGET_SYSTEM=ubuntu-16.04-32-base
            RUN_SNAPD=false
            ;;
        update-amazon-linux-2)
            SOURCE_SYSTEM=amazon-linux-2-64-base
            TARGET_SYSTEM=amazon-linux-2-64
            RUN_SNAPD=true
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

run_task_google "$TASK"
