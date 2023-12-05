#!/bin/bash

_get_zone(){
    if [ "$SPREAD_BACKEND" == "google-arm" ]; then
        ZONE=us-central1-a
    fi
    echo "$ZONE"
}

create_image_from_snapshot(){
    local IMAGE=$1
    local FAMILY=$2
    local DESCRIPTION="$3"
    local SNAPSHOT=$4
    gcloud compute images create "$IMAGE" --project "$GCE_PROJECT" --family "$FAMILY" --description "$DESCRIPTION" --source-snapshot "$SNAPSHOT"
}

create_image_from_snapshot_with_licenses(){
    local IMAGE=$1
    local FAMILY=$2
    local DESCRIPTION="$3"
    local SNAPSHOT=$4
    local LICENSES=$5
    gcloud compute images create "$IMAGE" --project "$GCE_PROJECT" --family "$FAMILY" --description "$DESCRIPTION" --source-snapshot "$SNAPSHOT" --licenses "$LICENSES"
}

create_image_from_snapshot_with_os_features(){
    local IMAGE=$1
    local FAMILY=$2
    local DESCRIPTION="$3"
    local SNAPSHOT=$4
    local OS_FEATURES=$5
    gcloud compute images create "$IMAGE" --project "$GCE_PROJECT" --family "$FAMILY" --description "$DESCRIPTION" --source-snapshot "$SNAPSHOT" --guest-os-features="$OS_FEATURES"
}

create_image_from_bucket(){
    local IMAGE=$1
    local FAMILY=$2
    local DESCRIPTION="$3"
    local IMAGE_FILE=$4
    gcloud compute images create "$IMAGE" --project "$GCE_PROJECT" --family "$FAMILY" --description "$DESCRIPTION" --source-uri "gs://$BUCKET_NAME/$IMAGE_FILE"
}

delete_image(){
    local IMAGE=$1
    local FAMILY=$2
    local image_name=$(gcloud compute images list --project "$GCE_PROJECT" --filter "family ~ ^$FAMILY$ AND name = $IMAGE" --format json | jq -r '.[]|.name')

    if ! [ -z "$image_name" ]; then
        gcloud compute images delete "$IMAGE" --project "$GCE_PROJECT" --quiet
    fi
}

get_latest_image_name(){
    local FAMILY=$1
    echo $(gcloud compute images describe-from-family "$FAMILY" --project "$GCE_PROJECT" --format json 2>/dev/null | jq -r '.name')
}

get_ordered_image_names(){
    local FAMILY=$1
    # Get by default the latest images first
    local ORDER=${2:-~creationTimestamp}

    if [ -z "$FAMILY" ]; then
        echo "Family required to retrieve images, exiting..."
        exit 1
    fi
    gcloud compute images list --project "$GCE_PROJECT" --sort-by "$ORDER" --format json --filter "family = $FAMILY" | jq -r ".[] | select(.family==\"$FAMILY\") | .name"
}

deprecate_old_images(){
    local FAMILY=$1
    local SKIP_IMAGE=$2
    local latest_image_name=$(gcloud compute images describe-from-family "$FAMILY" --project "$GCE_PROJECT" --format json | jq -r '.name')
    echo "Skip Image: ${SKIP_IMAGE}"
    echo "Latest Image: ${latest_image_name}"

    local old_images
    if [ -z "$SKIP_IMAGE" ]; then
        old_images=$(gcloud compute images list --project "$GCE_PROJECT" --filter "family ~ ^$FAMILY$ AND -name = ${latest_image_name}" --format json | jq -r '.[]|.name')
    else
        old_images=$(gcloud compute images list --project "$GCE_PROJECT" --filter "family ~ ^$FAMILY$ AND NOT (name = ${latest_image_name} OR name = ${SKIP_IMAGE})" --format json | jq -r '.[]|.name')
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
    local deprecated_images=$(gcloud compute images list --project "$GCE_PROJECT" --filter "deprecated" --show-deprecated --no-standard-images --format json | jq -r '.[]|.name')

    if [ -z "${deprecated_images}" ]; then
        echo "No deprecated images."
    else
        for image in ${deprecated_images}; do
            echo "Deleting deprecated image $image ..."
            gcloud compute images delete --project "$GCE_PROJECT" "$image" --quiet
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
    local CURR_ZONE
    if [ -d $TEMPORARY_PATH ]; then
        rm -rf $TEMPORARY_PATH
    fi

    mv "$PROJECT_PATH" "$TEMPORARY_PATH"
    sync
    CURR_ZONE="$(_get_zone)"
    gcloud compute disks snapshot "$DISK" --project "$GCE_PROJECT" --zone "$CURR_ZONE" --snapshot-names "$DISK"
    mv "$TEMPORARY_PATH" "$PROJECT_PATH"
}

delete_snapshot(){
    local SNAPSHOT=$1
    local snapshot_name=$(gcloud compute snapshots list --project "$GCE_PROJECT" --filter "name = $SNAPSHOT" --format json | jq -r '.[]|.name')

    if ! [ -z "$snapshot_name" ]; then
        gcloud compute snapshots delete "$SNAPSHOT" --project "$GCE_PROJECT" --quiet
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
    if [ -n "$latest_image_name" ]; then
        deprecate_old_images "$FAMILY" "$latest_image_name"
    fi
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
    if [ -n "$latest_image_name" ]; then
        deprecate_old_images "$FAMILY" "$latest_image_name"
    fi
}

create_image_from_disk_with_os_features(){
    local IMAGE=$1
    local FAMILY=$2
    local DESCRIPTION="$3"
    local DISK=$4
    local OS_FEATURES=$5

    local latest_image_name=$(get_latest_image_name "$FAMILY")
    create_snapshot_from_disk "$DISK"
    delete_image "$IMAGE" "$FAMILY"
    create_image_from_snapshot_with_os_features "$IMAGE" "$FAMILY" "$DESCRIPTION" "$DISK" "$OS_FEATURES"
    if [ -n "$latest_image_name" ]; then
        deprecate_old_images "$FAMILY" "$latest_image_name"
    fi
}

create_image_from_image(){
    local IMAGE=$1
    local FAMILY=$2
    local DESCRIPTION="$3"
    local SOURCE_IMAGE=$4

    local latest_image_name=$(get_latest_image_name "$FAMILY")
    delete_image "$IMAGE" "$FAMILY"
    gcloud compute images create "$IMAGE" --family "$FAMILY" --project "$GCE_PROJECT" --description "$DESCRIPTION" --source-image "$SOURCE_IMAGE"
    if [ -n "$latest_image_name" ]; then
        deprecate_old_images "$FAMILY" "$latest_image_name"
    fi
}

delete_latest_image_from_family(){
    local FAMILY=$1
    local latest_image_name=$(get_latest_image_name "$FAMILY")
    delete_image "$latest_image_name" "$FAMILY"
}

number_of_images_from_family(){
    gcloud compute images list --filter "family = $FAMILY" --project "$GCE_PROJECT" --format json | jq '. | length'
}
