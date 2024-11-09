#!/bin/bash

show_help() {
    echo "usage: openstack.sh update-image --task <task-name> --source-system <source-system> --target-image <target-image-name>"
    echo ""
    echo "Create and update images for openstack"
    echo ""
    echo "examples:"
    echo "./lib/openstack.sh add-image --task fedora-40-64 [--image-url <URL>] --target-image snapd-spread/fedora-40-64-base-v$(date +'%Y%m%d')"
    echo "./lib/openstack.sh add-image --task fedora-41-64 [--image-url <URL>] --target-image snapd-spread/fedora-41-64-base-v$(date +'%Y%m%d')"
    echo ""
    echo "./lib/openstack.sh update-image --task ubuntu-20.04-64 --source-system ubuntu-20.04-64-base --target-image snapd-spread/ubuntu-20.04-64-v$(date +'%Y%m%d')"
    echo "./lib/openstack.sh update-image --task ubuntu-22.04-64 --source-system ubuntu-22.04-64-base --target-image snapd-spread/ubuntu-22.04-64-v$(date +'%Y%m%d')"
    echo "./lib/openstack.sh update-image --task ubuntu-24.04-64 --source-system ubuntu-24.04-64-base --target-image snapd-spread/ubuntu-24.04-64-v$(date +'%Y%m%d')"
    echo "./lib/openstack.sh update-image --task fedora-40-64 --source-system fedora-40-64-base --target-image snapd-spread/fedora-40-64-v$(date +'%Y%m%d')"
    echo "./lib/openstack.sh update-image --task opensuse-15.5-64 --source-system opensuse-15.5-64-base --target-image snapd-spread/opensuse-15.5-64-v$(date +'%Y%m%d')"
    echo "./lib/openstack.sh update-image --task debian-12-64 --source-system debian-12-64-base --target-image snapd-spread/debian-12-64-v$(date +'%Y%m%d')"
    echo "./lib/openstack.sh update-image --task centos-9-64 --source-system centos-9-64-base --target-image snapd-spread/centos-9-64-v$(date +'%Y%m%d')"
}

update_image(){
    if [ $# -eq 0 ]; then
        show_help
        exit 0
    fi

    task=""
    source_system=""
    target_image=""
    while [ $# -gt 0 ]; do
        case "$1" in
            -h|--help)
                show_help
                exit 0
                ;;
            --task)
                task="$2"
                shift 2
                ;;
            --source-system)
                source_system="$2"
                shift 2
                ;;
            --target-image)
                target_image="$2"
                shift 2
                ;;
            *)
                echo "parameter non supported: $1"
                show_help
                exit 1
                ;;
        esac
    done

    set -ex

    # Run the update image task with reuse to keep the instance after the update is completed
    rm -f .spread-reuse*
    spread_failed=false
    (set -o pipefail; spread -reuse openstack:"$source_system":tasks/openstack/update-image/"$task" | tee spread.log)
    if [ ! $? -eq 0 ]; then
        spread_failed=true
    fi

    # Get the instance name
    instance_name="$(grep -E ".*Keeping.*(.*).*" < spread.log | awk -F'[()]' '{print $2}')"

    #check the instance name is correct
    test -n "$instance_name"

    # stop the instance before creating the snapshot
    openstack server stop "$instance_name"
    for _ in $(seq 10); do
        if openstack server show "$instance_name" | grep 'OS-EXT-STS:vm_state.*stopped'; then
            break
        fi
        sleep 5
    done

    # Create the snapshot just when the spread task didn't fail
    if [ "$spread_failed" = false ]; then
        # create the snapshot
        openstack server image create --name "$target_image" "$instance_name"
        for _ in $(seq 10); do
            if openstack image list | grep "$target_image .*|.*active"; then
                break
            fi
            sleep 10
        done
    fi    
    
    # delete the instance
    openstack server delete "$instance_name"
    rm -f spread.log

    set +ex
}

add_image() {
    if [ $# -eq 0 ]; then
        show_help
        exit 0
    fi
    
    task=""
    image_url=""
    target_image=""
    while [ $# -gt 0 ]; do
        case "$1" in
            -h|--help)
                show_help
                exit 0
                ;;
            --task)
                task="$2"
                shift 2
                ;;
            --image-url)
                image_url="$2"
                shift 2
                ;;
            --target-image)
                target_image="$2"
                shift 2
                ;;
            *)
                echo "parameter non supported: $1"
                show_help
                exit 1
                ;;
        esac
    done

    set -ex

    if [ -z "$task" ]; then
        echo "A task needs to be defined"
        exit 1
    fi
    if [ -z "$target_image" ]; then
        echo "A target image needs to be defined"
        exit 1
    fi
    if ! [ -d tasks/openstack/add-image/"$task" ]; then
        echo "There is not task tasks/openstack/add-image/$task"
        echo "Make sure the script is executed from the project root dir"
        exit 1
    fi
    if ! [ -f ./sa.json ]; then
        echo "The sa.json files needs to be in the project root dir"
        exit 1
    fi

    # Clean any image that could remain in the current dir
    rm ./*.qcow2*

    # export variables
    export SPREAD_IMAGE_URL=
    if [ -n "$image_url" ]; then
        export SPREAD_IMAGE_URL="$image_url"
    fi
    export SPREAD_IMAGE_NAME="${task}-base.qcow2"
    export SPREAD_GOOGLE_KEY="./sa.json"
    spread google:ubuntu-22.04-64:tasks/openstack/add-image/"$task"
    
    # Get the image and register it in openstack
    wget -q https://storage.googleapis.com/snapd-spread-tests/images/openstack/"$SPREAD_IMAGE_NAME"
    openstack image create --file "$SPREAD_IMAGE_NAME" "$target_image"

    # clean up
    rm "$SPREAD_IMAGE_NAME"
    unset SPREAD_IMAGE_URL
    unset SPREAD_IMAGE_NAME
    unset SPREAD_GOOGLE_KEY
}

main() {
    if [ $# -eq 0 ]; then
        show_help
        exit 0
    fi

    local subcommand="$1"
    local action=
    while [ $# -gt 0 ]; do
        case "$1" in
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                action=$(echo "$subcommand" | tr '-' '_')
                shift
                break
                ;;
        esac
    done

    if [ -z "$(declare -f "$action")" ]; then
        echo "openstack.sh: no such command: $subcommand" >&2
        show_help
        exit 1
    fi

    "$action" "$@"
}

main "$@"