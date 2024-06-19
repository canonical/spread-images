#!/bin/bash -x

show_help() {
    echo "usage: openstack.sh update-image <task-name> <source-system> <target-image-name>"
    echo ""
    echo "Create and update images for openstack"
}

update_image(){
    task=$1
    source_system=$2
    target_image=$3
    
    # Run the update image task with reuse to keep the instance after the update is completed
    rm -f .spread-reuse*
    spread -reuse openstack:"$source_system":tasks/openstack/update-image/"$task" | tee spread.log

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

    # create the snapshot
    openstack server image create --name "$target_image" "$instance_name"
    for _ in $(seq 10); do
        if openstack image list | grep "$target_image .*|.*active"; then
            break
        fi
        sleep 10
    done
    
    
    # delete the instance
    openstack server delete "$instance_name"
    rm -f spread.log
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