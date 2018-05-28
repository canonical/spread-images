#!/bin/bash

create_image_from_snapshot(){
    local IMAGE=$1
    local FAMILY=$2
    local DESCRIPTION=$3
    local SNAPSHOT=$4
    gcloud compute images create "$IMAGE" --family "$FAMILY" --description "$DESCRIPTION" --source-snapshot "$SNAPSHOT"
}

create_image_from_bucket(){
    local IMAGE=$1
    local FAMILY=$2
    local DESCRIPTION=$3
    local IMAGE_FILE=$4
    gcloud compute images create "$IMAGE" --family "$FAMILY" --description "$DESCRIPTION" --source-uri "gs://$BUCKET_NAME/$IMAGE_FILE"
}

delete_image(){
    local IMAGE=$1
    local image_name=$(gcloud compute images list --project "$GCE_PROJECT" --filter "family = $FAMILY AND name = $IMAGE" --format json | jq -r '.[]|.name')

    if ! [ -z "$image_name" ]; then
        gcloud compute images delete "$IMAGE" --quiet
    fi
}

get_latest_image_name(){
    local FAMILY=$1
    echo $(gcloud compute images describe-from-family "$FAMILY" --project "$GCE_PROJECT" --format json | jq -r '.name')
}

deprecate_old_images(){
    local FAMILY=$1
    local SKIP_IMAGE=$2
    local latest_image_name=$(gcloud compute images describe-from-family "$FAMILY" --project "$GCE_PROJECT" --format json | jq -r '.name')
    echo "Skip Image: ${SKIP_IMAGE}"
    echo "Latest Image: ${latest_image_name}"

    if [ -z "$SKIP_IMAGE" ]; then
        local old_images=$(gcloud compute images list --project "$GCE_PROJECT" --filter "family = $FAMILY AND -name = ${latest_image_name}" --format json | jq -r '.[]|.name')
    else
        local old_images=$(gcloud compute images list --project "$GCE_PROJECT" --filter "family = $FAMILY AND NOT (name = ${latest_image_name} OR name = ${SKIP_IMAGE})" --format json | jq -r '.[]|.name')
    fi

    if [ -z "${old_images}" ]; then
        echo "No old images."
    else
        for i in ${old_images}; do
            echo "Deprecate old image ${i} ..."
            gcloud compute images deprecate --project "$GCE_PROJECT" "${i}" --state DEPRECATED --replacement "${latest_image_name}"
            echo ""
        done
    fi
}

delete_deprecated_images(){
    local FAMILY=$1
    local latest_image_name=$(gcloud compute images describe-from-family "$FAMILY" --project "$GCE_PROJECT" --format json | jq -r '.name')
    echo "Latest Image: ${latest_image_name}"

    local old_images=$(gcloud compute images list --project "$GCE_PROJECT" --filter "family = $FAMILY AND -name = ${latest_image_name}" --format json | jq -r '.[]|.name')

    if [ -z "${old_images}" ]; then
        echo "No old images."
    else
        for i in ${old_images}; do
            echo "Deprecate old image ${i} ..."
            gcloud compute images deprecate --project "$GCE_PROJECT" "${i}" --state DEPRECATED --replacement "${latest_image_name}"
            echo ""
        done
    fi
}

copy_image_to_bucket(){
    local IMAGE_FILE=$1
    gsutil cp "$IMAGE_FILE" "gs://$BUCKET_NAME/"
}

create_snapshot_from_disk(){
    local DISK=$1
    local TEMPORARY_PATH=$(mktemp -t -d spread.XXXXX)
    if [ -d $TEMPORARY_PATH ]; then
        rm -rf $TEMPORARY_PATH
    fi

    mv "$PROJECT_PATH" "$TEMPORARY_PATH"
    sync
    gcloud compute disks snapshot "$DISK" --zone "$ZONE" --snapshot-names "$DISK"
    mv "$TEMPORARY_PATH" "$PROJECT_PATH"
}

delete_snapshot(){
    local SNAPSHOT=$1
    local snapshot_name=$(gcloud compute snapshots list --project "$GCE_PROJECT" --filter "name = $SNAPSHOT" --format json | jq -r '.[]|.name')

    if ! [ -z "$snapshot_name" ]; then
        gcloud compute snapshots delete "$SNAPSHOT" --quiet
    fi
}

create_image_from_disk(){
    local IMAGE=$1
    local FAMILY=$2
    local DESCRIPTION=$3
    local DISK=$4

    local latest_image_name=$(get_latest_image_name "$FAMILY")
    create_snapshot_from_disk "$DISK"
    delete_image "$IMAGE"
    create_image_from_snapshot "$IMAGE" "$FAMILY" "$DESCRIPTION" "$DISK"
    deprecate_old_images "$FAMILY" "$latest_image_name"
}
