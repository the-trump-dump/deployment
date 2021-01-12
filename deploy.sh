#!/usr/bin/env bash
set -e
set -o pipefail



echo "Deploying This Week In..."
SECRETS_FN=twi-configmap.env
cat <<EOF >${SECRETS_FN}
VUE_APP_SERVICE_ROOT=https://ttd-editor-api.cfapps.io
SPRING_R2DBC_USERNAME=$DB_USER
SPRING_R2DBC_PASSWORD=$DB_PW
SPRING_R2DBC_URL=r2dbc:postgres://$DB_HOST/$DB_DB
EOF
cat $SECRETS_FN


kubectl apply -k .
rm $SECRETS_FN

