#!/bin/bash

create_image_from_snapshot(){
    IMAGE=$1
    FAMILY=$2
    DESCRIPTION=$3
    SNAPSHOT=$4
    gcloud compute images create "$IMAGE" --family "$FAMILY" --description "$DESCRIPTION" --source-snapshot "$SNAPSHOT"
}

create_image_from_bucket(){
    IMAGE=$1
    FAMILY=$2
    DESCRIPTION=$3
    IMAGE_FILE=$4
    gcloud compute images create "$IMAGE" --family "$FAMILY" --description "$DESCRIPTION" --source-uri "gs://$BUCKET_NAME/$IMAGE_FILE"
}

delete_image(){
    IMAGE=$1
    image_name=$(gcloud compute images list --project $GCE_PROJECT --filter "family = $FAMILY AND name = $IMAGE" --format json | jq -r '.[]|.name')

    if ! [ -z $image_name]; then
        gcloud compute images delete "$IMAGE" --quiet
    fi
}

deprecate_old_images(){
  FAMILY=$1
  latest_image_name=$(gcloud compute images describe-from-family $FAMILY --project $GCE_PROJECT --format json | jq -r '.name')
  echo "Latest Image: ${latest_image_name}"

  old_images=$(gcloud compute images list --project $GCE_PROJECT --filter "family = $FAMILY AND -name = ${latest_image_name}" --format json | jq -r '.[]|.name')

  if [ -z "${old_images}" ]; then
    echo "No old images."
  else
    for i in ${old_images}; do
      echo "Deprecate old image ${i} ..."
      gcloud compute images deprecate --project $GCE_PROJECT ${i} --state DEPRECATED --replacement ${latest_image_name}
      echo ""
    done
  fi
}

delete_deprecated_images(){
  FAMILY=$1
  latest_image_name=$(gcloud compute images describe-from-family $FAMILY --project $GCE_PROJECT --format json | jq -r '.name')
  echo "Latest Image: ${latest_image_name}"

  old_images=$(gcloud compute images list --project $GCE_PROJECT --filter "family = $FAMILY AND -name = ${latest_image_name}" --format json | jq -r '.[]|.name')

  if [ -z "${old_images}" ]; then
    echo "No old images."
  else
    for i in ${old_images}; do
      echo "Deprecate old image ${i} ..."
      gcloud compute images deprecate --project $GCE_PROJECT ${i} --state DEPRECATED --replacement ${latest_image_name}
      echo ""
    done
  fi
}

copy_image_to_bucket(){
  IMAGE_FILE=$1
  gsutil cp "$IMAGE_FILE" "gs://$BUCKET_NAME/"
}

create_snapshot_from_disk(){
    DISK=$1
    TEMPORAL_PATH=/tmp/spread
    if [ -d $TEMPORAL_PATH ]; then
        rm -rf $TEMPORAL_PATH
    fi

    mv $PROJECT_PATH $TEMPORAL_PATH
    sync
    gcloud compute disks snapshot $DISK --zone $ZONE --snapshot-names $DISK
    mv $TEMPORAL_PATH $PROJECT_PATH
}

delete_snapshot(){
    SNAPSHOT=$1
    snapshot_name=$(gcloud compute snapshots list --project $GCE_PROJECT --filter "name = $SNAPSHOT" --format json | jq -r '.[]|.name')

    if ! -z $snapshot_name; then
        gcloud compute snapshots delete "$SNAPSHOT" --quiet
    fi
}
