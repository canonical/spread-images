#!/bin/bash

list_orphan_volumes(){
    openstack volume list --project stg-snapd-env_project -f json > volumes.json

    in_use_volumes="$(jq -r '.[] | select( .Status == "in-use" ) | .ID ' volumes.json)"
    in_use_servers="$(openstack server list -c ID -f value)"
    for volume_id in $in_use_volumes; do
        openstack volume show $volume_id -c attachments -f json 2>/dev/null > attachments.json
        if [ -s attachments.json ]; then
            server_id="$(jq -r '.attachments[0].server_id' attachments.json)"
            if [ -z "$server_id" ] || [ "$server_id" == null ]; then
                echo "$volume_id"
            else
                if ! grep -q "$server_id" <<< "$in_use_servers"; then
                    echo "$volume_id"
                fi
            fi
        fi
        rm attachments.json
    done

    error_volumes="$(jq -r '.[] | select( .Status == "error" ) | .ID ' volumes.json)"
    for volume_id in $error_volumes; do
        echo "$volume_id"
    done

    attaching_volumes="$(jq -r '.[] | select( .Status == "attaching" ) | .ID ' volumes.json)"
    for volume_id in $attaching_volumes; do
        echo "$volume_id"
    done

    creating_volumes="$(jq -r '.[] | select( .Status == "creating" ) | .ID ' volumes.json)"
    for volume_id in $creating_volumes; do
        openstack volume show $volume_id -c attachments -f json 2>/dev/null > attachments.json
        if [ -s attachments.json ]; then
            attachments="$(jq -r '.attachments' attachments.json)"
            if [ "$attachments" = "[]" ]; then
                echo "$volume_id"
            fi
        fi
        rm attachments.json
    done

    reserved_volumes="$(jq -r '.[] | select( .Status == "reserved" ) | .ID ' volumes.json)"
    for volume_id in $reserved_volumes; do
        openstack volume show $volume_id -c attachments -f json 2>/dev/null > attachments.json
        if [ -s attachments.json ]; then
            attachments="$(jq -r '.attachments' attachments.json)"
            if [ "$attachments" = "[]" ]; then
                echo "$volume_id"
            fi
        fi
        rm attachments.json
    done
    
    rm volumes.json
}

list_orphan_volumes

