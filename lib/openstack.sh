#!/bin/bash

show_help() {
    echo "usage: openstack.sh add-image <PARAMS>"
    echo "       openstack.sh update-image <PARAMS>"
    echo "       openstack.sh clean-images"
    echo "       openstack.sh clean-volumes [STATE]"
    echo "       openstack.sh list-orphan-volumes"
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
    echo "./lib/openstack.sh add-image --task debian-sid-64 --target-image snapd-base/debian-sid-64-base-v$(date +'%Y%m%d')"
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
    echo "./lib/openstack.sh update-image --task centos-9-64 --source-system centos-9-64-base --target-system centos-9-64 --target-image snapd-spread/centos-9-64-v$(date +'%Y%m%d')"
    echo "./lib/openstack.sh update-image --task debian-12-64 --source-system debian-12-64-base --target-system debian-12-64 --target-image snapd-spread/debian-12-64-v$(date +'%Y%m%d')"
    echo "./lib/openstack.sh update-image --task debian-sid-64 --source-system debian-sid-64-base --target-system debian-sid-64 --target-image snapd-spread/debian-sid-64-v$(date +'%Y%m%d')"
    echo "./lib/openstack.sh update-image --task fedora-40-64 --source-system fedora-40-64-base --target-system fedora-40-64 --target-image snapd-spread/fedora-40-64-v$(date +'%Y%m%d')"
    echo "./lib/openstack.sh update-image --task fedora-41-64 --source-system fedora-41-64-base --target-system fedora-41-64 --target-image snapd-spread/fedora-41-64-v$(date +'%Y%m%d')"
    echo "./lib/openstack.sh update-image --task opensuse-15.5-64 --source-system opensuse-15.5-64-base --target-system opensuse-15.5-64 --target-image snapd-spread/opensuse-15.5-64-v$(date +'%Y%m%d')"
    echo "./lib/openstack.sh update-image --task opensuse-15.6-64 --source-system opensuse-15.6-64-base --target-system opensuse-15.6-64 --target-image snapd-spread/opensuse-15.6-64-v$(date +'%Y%m%d')"
    echo "./lib/openstack.sh update-image --task opensuse-tumbleweed-64 --source-system opensuse-tumbleweed-64-base --target-system opensuse-tumbleweed-64 --target-image snapd-spread/opensuse-tumbleweed-64-v$(date +'%Y%m%d')"
    echo "./lib/openstack.sh update-image --task ubuntu-20.04-64 --source-system ubuntu-20.04-64-base --target-system ubuntu-20.04-64 --target-image snapd-spread/ubuntu-20.04-64-v$(date +'%Y%m%d')"
    echo "./lib/openstack.sh update-image --task ubuntu-22.04-64 --source-system ubuntu-22.04-64-base --target-system ubuntu-22.04-64 --target-image snapd-spread/ubuntu-22.04-64-v$(date +'%Y%m%d')"
    echo "./lib/openstack.sh update-image --task ubuntu-24.04-64 --source-system ubuntu-24.04-64-base --target-system ubuntu-24.04-64 --target-image snapd-spread/ubuntu-24.04-64-v$(date +'%Y%m%d')"
    echo ""
    echo "examples for base images:"
    echo "./lib/openstack.sh update-image --task opensuse-15.5-64-base --source-system opensuse-15.5-64-base --target-system opensuse-15.5-64-base --target-image snapd-base/opensuse-15.5-64-base-v$(date +'%Y%m%d')"
    echo "./lib/openstack.sh update-image --task opensuse-15.6-64-base --source-system opensuse-15.6-64-base --target-system opensuse-15.6-64-base --target-image snapd-base/opensuse-15.6-64-base-v$(date +'%Y%m%d')"
    echo "./lib/openstack.sh update-image --task opensuse-tumbleweed-64-base --source-system opensuse-tumbleweed-64-base --target-system opensuse-tumbleweed-64-base --target-image snapd-base/opensuse-tumbleweed-64-base-v$(date +'%Y%m%d')"
}

update_image(){
    if [ $# -eq 0 ]; then
        show_help_update
        exit 0
    fi

    task=""
    source_system=""
    target_system=""
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
            --target-system)
                target_system="$2"
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

    set -x

    if [ -z "$source_system" ] || [ -z "$target_system" ] || [ -z "$target_image" ]; then
        echo "Required parametes: source-system, target-system and target-image"
        exit 1
    fi

    # Run the update image task with reuse to keep the instance after the update is completed
    rm -f .spread-reuse*
    spread_failed="false"
    start_failed="false"
    os_failed="false"

    rm -f .spread-reuse.yaml*
    if ! spread -reuse openstack:"$source_system":tasks/openstack/update-image/"$task"; then
        spread_failed="true"
    fi

    # Get the instance name
    if [ -f .spread-reuse.yaml ]; then
        instance_name="$(cat .spread-reuse.yaml | grep "name:" | cut -d: -f2 | sed 's/ //g')"
    else
        echo "Spread instance info not found, exiting..."
        exit 1
    fi

    #check the instance name is correct
    if [ -z "$instance_name" ]; then
        echo "Instance name not detected in spread-reuse file, exiting..."
        exit 1
    fi

    volume_id="$(_volume_for_server "$instance_name")"
    if [ -z "$volume_id" ]; then
        echo "Error: Volume ID empty"
        os_failed="true"
    fi

    # delete the instance before creating the image
    openstack server delete "$instance_name"

    # wait until the volume status is available
    for _ in $(seq 20); do
        if [ "$(openstack volume show -f value -c status "$volume_id")" == "available" ]; then
            break
        else
            sleep 3
        fi
    done

    # Create the snapshot just when the spread task didn't fail
    if [ "$spread_failed" == "false" ]; then
        # create the image
        # Openstack code (openstack image create) checks tty status: it needs a tty (even if you create from a volume),
        # that the ci runners may not provide. So it is needed to "fake" a tty to execute the command.
        target_id="$(true | openstack image create -f value -c image_id --volume "$volume_id" "$target_image")"

        if [ -z "$target_id" ]; then
           echo "Error: Image not created"
           os_failed=true
        fi

        if openstack image show "$target_id" | grep "No Image found"; then
           echo "Error: Image not found"
           os_failed=true
        fi

        if [ "$os_failed" == "false" ]; then
            for _ in $(seq 20); do
                if openstack image show -c status -f value "$target_id" | grep -E "^active"; then
                    openstack image set --property "family=$task" "$target_id"
                    openstack image set --tag "family=$task" "$target_id"
                    openstack image set --tag "test-image" "$target_id"
                    openstack image set --shared "$target_id"
                    break
                fi
                sleep 30
             done
         fi
     fi

    if [ "$spread_failed" == "false" ] && [ "$os_failed" == "false" ]; then
        echo "Checking the new image boots properly"
        if ! spread openstack:"$target_system":tasks/openstack/common/start-instance; then
            start_failed=true
        fi
    fi

    # clean old images
    if [ "$spread_failed" == "false" ] && [ "$os_failed" == "false" ] && [ "$start_failed" == "false" ]; then
        _deactivate_old_images "$target_id" "$task" "test-image"
        openstack volume delete "$volume_id"
    fi

    # delete the instance
    openstack server delete "$instance_name"
    rm -f spread.log

    # delete the image is failed to start
    if [ "$start_failed" == "true" ]; then
        echo "Deleting image that failed to start after the update"
        openstack image delete "$target_id"
    fi

    # check spread and os commands didn't fail
    if [ "$spread_failed" == "true" ] || [ "$os_failed" == "true" ] || [ "$start_failed" == "true" ]; then
        exit 1
    fi

    set +x
}

_snapshot_for_image(){
    openstack image show "$1" -c properties -f json | jq -r '.properties.block_device_mapping' | jq '.[].snapshot_id' | tr -d '"'
}

_volume_for_snapshot(){
    openstack volume snapshot show "$1" -c volume_id -f value
}

_volume_for_server(){
    openstack server show "$1" -c volumes_attached -f json | jq -r '.volumes_attached[0].id' | tr -d '"'
}

_snapshot_for_volume(){
    openstack volume show "$1" -c snapshot_id -f value
}

count_used_volumes(){
    openstack volume summary -f value -c 'Total Count'
}

count_used_snapshots(){
    openstack volume snapshot list -f value -c ID | wc -l
}

count_used_servers(){
    openstack server list -f value -c ID | wc -l
}

list_orphan_volumes(){
    echo "ERROR STATUS"
    error_volumes="$(openstack volume list --status error -f value --column ID)"
    for volume_id in $error_volumes; do
        echo "$volume_id"
    done
    echo ""

    echo "IN-USE STATUS"
    in_use_volumes="$(openstack volume list --status in-use -f value --column ID)"
    in_use_servers="$(openstack server list -c ID -f value)"
    for volume_id in $in_use_volumes; do
        server_id="$(openstack volume show $volume_id -c attachments -f json | jq -r '.attachments[0].server_id')"
        if [ -z "$server_id" ] || [ "$server_id" == null ]; then
            echo "$volume_id"
        else
            if ! grep -q "$server_id" <<< "$in_use_servers"; then
                echo "$volume_id"
            fi
        fi
    done
    echo ""

    echo "ATTACHING STATUS"
    attaching_volumes="$(openstack volume list --status attaching -f value --column ID)"
    for volume_id in $attaching_volumes; do
        echo "$volume_id"
    done
    echo ""    

    echo "CREATING STATUS"
    creating_volumes="$(openstack volume list --status creating -f value --column ID)"
    for volume_id in $creating_volumes; do
        attachments="$(openstack volume show -f value -c attachments "$volume_id")"
        if [ "$attachments" = "[]" ]; then
            echo "$volume_id"
        fi
    done

    echo "RESERVED STATUS"
    reserved_volumes="$(openstack volume list --status reserved -f value --column ID)"
    for volume_id in $reserved_volumes; do
        attachments="$(openstack volume show -f value -c attachments "$volume_id")"
        if [ "$attachments" = "[]" ]; then
            echo "$volume_id"
        fi
    done
}

clean_volumes(){
    set -x
    STATUS=${1:-}

    if [ -n "$STATUS" ]; then
        status_volumes="$(openstack volume list --status "$STATUS" -f value --column ID)"
        if [ -z "$status_volumes" ]; then
            echo "No volumes in error $STATUS"
        fi
        for volume_id in $status_volumes; do
            if openstack volume delete "$volume_id"; then
                echo "volume $volume_id deleted"
            fi
        done
        exit 0
        
    fi

    error_volumes="$(openstack volume list --status error -f value --column ID)"
    if [ -z "$error_volumes" ]; then
        echo "No volumes in error status"
    fi
    for volume_id in $error_volumes; do
        if openstack volume delete "$volume_id"; then
            echo "volume $volume_id deleted (error status)"
        fi
    done

    in_use_volumes="$(openstack volume list --status in-use -f value --column ID)"
    in_use_servers="$(openstack server list -c ID -f value)"
    for volume_id in $in_use_volumes; do
        server_id="$(openstack volume show $volume_id -c attachments -f json | jq -r '.attachments[0].server_id')"
        if [ -z "$server_id" ] || [ "$server_id" == null ]; then
            echo "No server id attached to the volume $volume_id"
        else
            echo "Server found $server_id"
            if grep -q "$server_id" <<< "$in_use_servers"; then
                echo "Server is being used"
            else
                echo "Server is not being used, deleting volume"
                #openstack volume set --detached "$volume_id"
                #openstack volume delete "$volume_id"
            fi
        fi
    done

    available_volumes="$(openstack volume list --status available -f value --column ID)"
    if [ -z "$available_volumes" ]; then
        echo "No volumes in available status"
    fi
    for volume_id in $available_volumes; do
        attachments="$(openstack volume show -f value -c attachments "$volume_id")"
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
        attachments="$(openstack volume show -f value -c attachments "$volume_id")"
        if [ "$attachments" = "[]" ]; then
            openstack volume delete "$volume_id"
            echo "volume $volume_id deleted (available status)"
        fi
    done

    set +x
}

clean_images(){
    set -x

    deactivated_images="$(openstack image list --status deactivated --private -f value --column ID)"
    if [ -z "$deactivated_images" ]; then
        echo "No deactivated images found"
        return
    fi

    for image_id in $deactivated_images; do
        echo "Found deactivated image: $image_id"
        snapshot_id="$(_snapshot_for_image "$image_id")"
        openstack image delete "$image_id"
        echo "Image deleted"

        if [ -n "$snapshot_id" ]; then
            echo "Found snapshot associated to the image: $snapshot_id"
            openstack volume snapshot delete "$snapshot_id"
        fi        
    done

    set +x
}

_deactivate_old_images(){
    image_id=$1
    family=$2
    type=$3

    if [ -z "$image_id" ] || [ -z "$family" ] || [ -z "$type" ]; then
        echo "Error: image_id, family and type cannot be empty, exiting..."
        exit 1
    fi

    active_images="$(openstack image list -f value --private --status active --tag "family=$family" --column ID)"
    for active_image in $active_images; do
        if [ "$active_image" != "$image_id" ]; then
            tags="$(openstack image show -c tags -f value "$active_image")"
            if grep -vq "$type" <<< "$tags"; then
                echo "Skipping image with different type"
            elif grep -vq "family=$family" <<< "$tags"; then
                echo "Skipping image with different family"
            else
                echo "Deactivating old image: $active_image"
                openstack image set --deactivate "$active_image"
            fi
        else
            echo "Skipping current image: $image_id"
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

    set -x

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

    set +x
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
