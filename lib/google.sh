#!/bin/bash

snapshot(){
    DISK=$1
    TEMPORAL_PATH=/tmp/spread
    if [ -e $TEMPORAL_PATH ]; then
        rm -rf $TEMPORAL_PATH
    fi
    mv $PROJECT_PATH $TEMPORAL_PATH
    gcloud compute disks snapshot $DISK --zone $ZONE --snapshot-names $DISK
    mv $TEMPORAL_PATH $PROJECT_PATH
}

deprecate (){
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