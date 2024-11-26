#!/bin/bash

show_help() {
    echo "usage: openstack.sh add-image <PARAMS>"
    echo "       openstack.sh update-image <PARAMS>"
    echo "       openstack.sh clean-images"
    echo "       openstack.sh clean-volumes"
    echo ""
    echo "For more details in specific commands"
}

show_help_add() {
    echo "usage: openstack.sh update-image --task <task-name> --source-system <source-system> --target-image <target-image-name>"
    echo ""
    echo "Create and update images for openstack"
    echo ""
    echo "examples:"
    echo "./lib/openstack.sh add-image --task centos-9-64 --target-image snapd-base/centos-9-64-base-v$(date +'%Y%m%d')"
    echo "./lib/openstack.sh add-image --task debian-12-64 --target-image snapd-base/debian-12-64-base-v$(date +'%Y%m%d')"
    echo "./lib/openstack.sh add-image --task fedora-40-64 --target-image snapd-base/fedora-40-64-base-v$(date +'%Y%m%d')"
    echo "./lib/openstack.sh add-image --task fedora-41-64 --target-image snapd-base/fedora-41-64-base-v$(date +'%Y%m%d')"
    echo "./lib/openstack.sh add-image --task opensuse-15.5-64 --target-image snapd-base/opensuse-15.5-64-base-v$(date +'%Y%m%d')"
    echo "./lib/openstack.sh add-image --task opensuse-15.6-64 --target-image snapd-base/opensuse-15.6-64-base-v$(date +'%Y%m%d')"
}

show_help_update() {
    echo "usage: openstack.sh update-image --task <task-name> --source-system <source-system> --target-image <target-image-name>"
    echo ""
    echo "Create and update images for openstack"
    echo ""
    echo "examples:"
    echo "./lib/openstack.sh update-image --task centos-9-64 --source-system centos-9-64-base --target-image snapd-spread/centos-9-64-v$(date +'%Y%m%d')"
    echo "./lib/openstack.sh update-image --task debian-12-64 --source-system debian-12-64-base --target-image snapd-spread/debian-12-64-v$(date +'%Y%m%d')"
    echo "./lib/openstack.sh update-image --task fedora-40-64 --source-system fedora-40-64-base --target-image snapd-spread/fedora-40-64-v$(date +'%Y%m%d')"
    echo "./lib/openstack.sh update-image --task fedora-41-64 --source-system fedora-41-64-base --target-image snapd-spread/fedora-41-64-v$(date +'%Y%m%d')"
    echo "./lib/openstack.sh update-image --task opensuse-15.5-64 --source-system opensuse-15.5-64-base --target-image snapd-spread/opensuse-15.5-64-v$(date +'%Y%m%d')"
    echo "./lib/openstack.sh update-image --task opensuse-15.6-64 --source-system opensuse-15.6-64-base --target-image snapd-spread/opensuse-15.6-64-v$(date +'%Y%m%d')"
    echo "./lib/openstack.sh update-image --task opensuse-tumbleweed-64 --source-system opensuse-tumbleweed-64-base --target-image snapd-spread/opensuse-tumbleweed-64-v$(date +'%Y%m%d')"
    echo "./lib/openstack.sh update-image --task ubuntu-20.04-64 --source-system ubuntu-20.04-64-base --target-image snapd-spread/ubuntu-20.04-64-v$(date +'%Y%m%d')"
    echo "./lib/openstack.sh update-image --task ubuntu-22.04-64 --source-system ubuntu-22.04-64-base --target-image snapd-spread/ubuntu-22.04-64-v$(date +'%Y%m%d')"
    echo "./lib/openstack.sh update-image --task ubuntu-24.04-64 --source-system ubuntu-24.04-64-base --target-image snapd-spread/ubuntu-24.04-64-v$(date +'%Y%m%d')"
}

update_image(){
    if [ $# -eq 0 ]; then
        show_help_update
        exit 0
    fi

    task=""
    source_system=""
    target_image=""
    while [ $# -gt 0 ]; do
        case "$1" in
            -h|--help)
                show_help_update
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
                show_help_update
                exit 1
                ;;
        esac
    done

    set -ex

    # Run the update image task with reuse to keep the instance after the update is completed
    rm -f .spread-reuse*
    spread_failed=false
    os_failed=false
    if ! (set -o pipefail; spread -reuse openstack:"$source_system":tasks/openstack/update-image/"$task" | tee spread.log); then
        spread_failed=true
    fi

    # Get the instance name
    instance_name="$(grep -E ".*Keeping.*(.*).*" < spread.log | awk -F'[()]' '{print $2}')"

    #check the instance name is correct
    test -n "$instance_name"

    # stop the instance before creating the snapshot
    openstack server stop "$instance_name"
    for _ in $(seq 10); do
        if openstack server show -c OS-EXT-STS:vm_state -f value "$instance_name" | grep 'stopped'; then
            break
        fi
        sleep 5
    done

    # Create the snapshot just when the spread task didn't fail
    if [ "$spread_failed" = false ]; then
        # create the snapshot
        target_id="$(openstack server image create --name "$target_image" --property "family=$task" -f value -c id "$instance_name")"
        if [ -z "$target_id" ]; then
            echo "Error: Image ID empty"
            os_failed=true
        fi

        if openstack image show "$target_id" | grep "No Image found"; then
            echo "Error: Image not found"
            os_failed=true
        fi

        for _ in $(seq 10); do
            if openstack image show -c status -f value "$target_id" | grep -E "^active"; then
                openstack image set --tag "family=$task" "$target_id"
                openstack image set --tag "test-image" "$target_id"
                openstack image set --private "$target_id"
                break
            fi
            sleep 10
        done
    fi    

    # clean old images
    if [ "$spread_failed" = false ] && [ "$os_failed" = false ]; then
        _deactivate_old_images "$target_id" "$task" "test-image"
    fi

    # delete the instance
    openstack server delete "$instance_name"
    rm -f spread.log

    set +ex
}

clean_volumes(){
    error_volumes="$(openstack volume list --status error -f value --column ID)"
    if [ -z "$error_volumes" ]; then
        echo "No volumes in error status"
    fi
    for volume_id in $error_volumes; do
        if openstack volume delete "$volume_id"; then
            echo "volume $volume_id deleted (error status)"
        fi
    done

    available_snapshots="$(openstack volume snapshot list --status available -f value --column ID)"
    if [ -z "$available_snapshots" ]; then
        echo "No snapshots in available status"
    fi
    for snapshot_id in $available_snapshots; do
        if openstack volume snapshot delete "$snapshot_id"; then
            echo "snapshot $snapshot_id deleted (available status)"
        fi
    done

    available_volumes="$(openstack volume list --status available -f value --column ID)"
    if [ -z "$available_volumes" ]; then
        echo "No volumes in available status"
    fi
    for volume_id in $available_volumes; do
        attachments="$(openstack volume show -f value -c attachments $volume_id)"
        if [ "$attachments" = "[]" ]; then
            if openstack volume delete "$volume_id"; then
                echo "volume $volume_id deleted (available status)"
            fi
        fi
    done

    creating_volumes="$(openstack volume list --status creating -f value --column ID)"
    if [ -z "$creating_volumes" ]; then
        echo "No volumes in available status"
    fi
    for volume_id in $creating_volumes; do
        attachments="$(openstack volume show -f value -c attachments $volume_id)"
        if [ "$attachments" = "[]" ]; then
            openstack volume delete "$volume_id"
            echo "volume $volume_id deleted (available status)"
        fi
    done

}

clean_images(){
    deactivated_images="$(openstack image list --status deactivated --private -f value --column ID)"
    if [ -z "$deactivated_images" ]; then
        echo "No deactivated images found"
        return
    fi

    for image_id in $deactivated_images; do
        echo "Found deactivated image: $image_id"
        openstack image delete "$image_id"
        echo "Image deleted"
    done
}

_deactivate_old_images(){
    image_id=$1
    family=$2
    type=$3

    if [ -z "$image_id" ] || [ -z "$family" ] || [ -z "$type" ]; then
        echo "Error: image_id, family and type cannot be empty, exiting..."
        exit 1
    fi

    active_images="$(openstack image list -f value --private --status active --tag "family=$family" --tag "$type" --column ID)"
    for active_image in $active_images; do
        if [ "$active_image" != "$image_id" ]; then
            echo "Found old image: $active_image"
            openstack image set --deactivate "$active_image"
            echo "Image deactivated"
        else
            echo "Skipping current image"
        fi
    done
}

add_image() {
    if [ $# -eq 0 ]; then
        show_help_add
        exit 0
    fi
    
    task=""
    image_url=""
    target_image=""
    while [ $# -gt 0 ]; do
        case "$1" in
            -h|--help)
                show_help_add
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
                show_help_add
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
    rm -f ./*.qcow2*

    # export variables
    export SPREAD_IMAGE_URL=
    if [ -n "$image_url" ]; then
        export SPREAD_IMAGE_URL="$image_url"
    fi

    image_format=qcow2
    export SPREAD_IMAGE_NAME="${task}-base.${image_format}"
    export SPREAD_GOOGLE_KEY="./sa.json"
    spread google:ubuntu-22.04-64:tasks/openstack/add-image/"$task"
    
    # Get the image and register it in openstack
    wget -q https://storage.googleapis.com/snapd-spread-tests/images/openstack/"$SPREAD_IMAGE_NAME"
    openstack image create --file "$SPREAD_IMAGE_NAME" --disk-format "$image_format" --property "family=$task" --private --tag "family=$task" --tag "base-image" "$target_image"

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
