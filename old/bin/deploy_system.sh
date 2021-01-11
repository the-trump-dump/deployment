#!/bin/bash
set -e

## This build assumes the use of Kustomize
## https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/
export BP_MODE_LOWERCASE=${BP_MODE_LOWERCASE:-development}
export ROOT_DIR=${PWD}
#export GCLOUD_ZONE=us-west1-b
export OD=${ROOT_DIR}/overlays/${BP_MODE_LOWERCASE}
export GKE_CLUSTER_NAME=bootiful-podcast-${BP_MODE_LOWERCASE}
export GCLOUD_PROJECT=${GCLOUD_PROJECT:-bootiful}
##
## Sensible defaults
export BP_RABBITMQ_MANAGEMENT_USERNAME=${BP_RABBITMQ_MANAGEMENT_USERNAME:-rmquser}
export BP_RABBITMQ_MANAGEMENT_PASSWORD=${BP_RABBITMQ_MANAGEMENT_PASSWORD:-rmqpw}
export POSTGRES_DB=${BP_POSTGRES_DB:-bp}
export POSTGRES_USER=${BP_POSTGRES_USERNAME:-bp}
export POSTGRES_PASSWORD=${BP_POSTGRES_PASSWORD:-pw}
export FS_NAME="bp-backup-${BP_MODE_LOWERCASE}-disk"

echo "Deploying to $BP_MODE_LOWERCASE "

gcloud --quiet beta compute disks describe $FS_NAME --zone $GCLOUD_ZONE ||
  gcloud --quiet beta compute disks create $FS_NAME --type=pd-balanced --size=200GB --zone $GCLOUD_ZONE

RMQ_SECRETS_FN=${OD}/../development/rabbitmq-secrets.env
PSQL_SECRETS_FN=${OD}/../development/postgresql-secrets.env

cat <<EOF >${RMQ_SECRETS_FN}
RABBITMQ_DEFAULT_USER=${BP_RABBITMQ_MANAGEMENT_USERNAME}
RABBITMQ_DEFAULT_PASS=${BP_RABBITMQ_MANAGEMENT_PASSWORD}
EOF


cat <<EOF >${PSQL_SECRETS_FN}
POSTGRES_DB=${POSTGRES_DB}
POSTGRES_USER=${POSTGRES_USER}
POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
EOF

kubectl apply -k ${OD}

rm $RMQ_SECRETS_FN
rm $PSQL_SECRETS_FN

cd ${GITHUB_WORKSPACE}/bin/
./run_postgresql_db_backup.sh



