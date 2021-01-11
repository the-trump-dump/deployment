#!/bin/bash
set -e

echo "Deploying to $BP_MODE_LOWERCASE "

function deploy_new_gke_cluster() {
  gcloud --quiet beta container --project $GCLOUD_PROJECT clusters create "${GKE_CLUSTER_NAME}" \
    --zone "$GCLOUD_ZONE" --no-enable-basic-auth --cluster-version "1.17.13-gke.600" \
    --machine-type "c2-standard-4" --image-type "COS" \
    --metadata disable-legacy-endpoints=true --scopes "compute-rw,gke-default" \
    --num-nodes "2" --enable-stackdriver-kubernetes --enable-ip-alias \
    --no-enable-master-authorized-networks \
    --addons HorizontalPodAutoscaling,HttpLoadBalancing --enable-autoupgrade --enable-autorepair --max-surge-upgrade 1 --max-unavailable-upgrade 0
}

gcloud container clusters list | grep $GKE_CLUSTER_NAME || deploy_new_gke_cluster
