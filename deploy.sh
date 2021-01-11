#!/usr/bin/env bash
set -e
set -o pipefail


echo "Deploying This Week In..."

SECRETS_FN=twi-configmap.env

cat <<EOF >${SECRETS_FN}
VUE_APP_SERVICE_ROOT=https://ttd-editor-api.cfapps.io
EOF

kubectl apply -k .
rm $SECRETS_FN

