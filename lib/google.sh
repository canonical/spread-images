#!/bin/bash

create_image_from_snapshot(){
    local IMAGE=$1
    local FAMILY=$2
    local DESCRIPTION="$3"
    local SNAPSHOT=$4
    gcloud compute images create "$IMAGE" --family "$FAMILY" --description "$DESCRIPTION" --source-snapshot "$SNAPSHOT"
}

create_image_from_snapshot_with_licenses(){
    local IMAGE=$1
    local FAMILY=$2
    local DESCRIPTION="$3"
    local SNAPSHOT=$4
    local LICENSES=$5
    gcloud compute images create "$IMAGE" --family "$FAMILY" --description "$DESCRIPTION" --source-snapshot "$SNAPSHOT" --licenses "$LICENSES"
}

create_image_from_bucket(){
    local IMAGE=$1
    local FAMILY=$2
    local DESCRIPTION="$3"
    local IMAGE_FILE=$4
    gcloud compute images create "$IMAGE" --family "$FAMILY" --description "$DESCRIPTION" --source-uri "gs://$BUCKET_NAME/$IMAGE_FILE"
}

delete_image(){
    local IMAGE=$1
    local FAMILY=$2
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

    local old_images
    if [ -z "$SKIP_IMAGE" ]; then
        old_images=$(gcloud compute images list --project "$GCE_PROJECT" --filter "family = $FAMILY AND -name = ${latest_image_name}" --format json | jq -r '.[]|.name')
    else
        old_images=$(gcloud compute images list --project "$GCE_PROJECT" --filter "family = $FAMILY AND NOT (name = ${latest_image_name} OR name = ${SKIP_IMAGE})" --format json | jq -r '.[]|.name')
    fi

    if [ -z "${old_images}" ]; then
        echo "No old images."
    else
        for i in ${old_images}; do
            echo "Deprecate old image ${i} ..."
            gcloud compute images deprecate --project "$GCE_PROJECT" "${i}" --state DEPRECATED --replacement "${latest_image_name}" --delete-in 5d
            echo ""
        done
    fi
}

delete_deprecated_images(){
    local FAMILY=$1
    local deprecated_images=$(gcloud compute images list --project "$GCE_PROJECT" --filter "family = $FAMILY AND state DEPRECATED" --format json | jq -r '.[]|.name')

    if [ -z "${deprecated_images}" ]; then
        echo "No deprecated images."
    else
        for i in ${deprecated_images}; do
            echo "Deleting deprecated image ${i} ..."
            gcloud compute images delete --project "$GCE_PROJECT" "${i}"
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
    local DESCRIPTION="$3"
    local DISK=$4

    local latest_image_name=$(get_latest_image_name "$FAMILY")
    create_snapshot_from_disk "$DISK"
    delete_image "$IMAGE" "$FAMILY"
    create_image_from_snapshot "$IMAGE" "$FAMILY" "$DESCRIPTION" "$DISK"
    deprecate_old_images "$FAMILY" "$latest_image_name"
}

create_image_from_disk_with_licences(){
    local IMAGE=$1
    local FAMILY=$2
    local DESCRIPTION="$3"
    local DISK=$4
    local LICENSES=$5

    local latest_image_name=$(get_latest_image_name "$FAMILY")
    create_snapshot_from_disk "$DISK"
    delete_image "$IMAGE" "$FAMILY"
    create_image_from_snapshot_with_licenses "$IMAGE" "$FAMILY" "$DESCRIPTION" "$DISK" "$LICENSES"
    deprecate_old_images "$FAMILY" "$latest_image_name"
}

create_image_from_image(){
    local IMAGE=$1
    local FAMILY=$2
    local DESCRIPTION="$3"
    local SOURCE_IMAGE=$4

    local latest_image_name=$(get_latest_image_name "$FAMILY")
    delete_image "$IMAGE" "$FAMILY"
    gcloud compute images create "$IMAGE" --family "$FAMILY" --description "$DESCRIPTION" --source-image "$SOURCE_IMAGE"
    deprecate_old_images "$FAMILY" "$latest_image_name"
}

delete_latest_image_from_family(){
    local FAMILY=$1
    local latest_image_name=$(get_latest_image_name "$FAMILY")
    delete_image "$latest_image_name" "$FAMILY"
}

number_of_images_from_family(){
    gcloud compute images list --filter "family = $FAMILY" --project "$GCE_PROJECT" --format json | jq '. | length'
}
