#!/usr/bin/env bash 

NS=$TWI_NS
CHART_NAME=twi-${NS}-helm-chart
INGEST_FEED_ENCODED_MAPPINGS=$( cat feed-mappings.json | base64 | tr -d '\n' )
INGEST_TWITTER_ENCODED_MAPPINGS=$( cat twitter-mappings.json | base64 | tr -d '\n' )

helm repo add this-week-in-charts https://this-week-in-charts.storage.googleapis.com 
helm repo add stable https://charts.helm.sh/stable
kubectl get namespaces 

function create_ip(){
    IPN=$1
    gcloud compute addresses list --format json | jq '.[].name' -r | grep $IPN || gcloud compute addresses create $IPN --global
}

function init(){
    create_ip ${NS}-twi-studio-ip 
    create_ip ${NS}-twi-bookmark-api-ip 
    kubectl get ns/$NS || kubectl create namespace ${NS} 
}

init 



HELM_COMMAND="install"
helm list --all-namespaces | grep $CHART_NAME  && HELM_COMMAND="upgrade"
helm $HELM_COMMAND  \
 --set twi.prefix=$NS \
 --set twi.domain=$TWI_DOMAIN \
 --set twi.postgres.username=$DB_USER \
 --set twi.postgres.password=$DB_PW \
 --set twi.postgres.host=$DB_HOST \
 --set twi.postgres.schema=$DB_DB \
 --set twi.redis.host=$REDIS_HOST \
 --set twi.redis.password=$REDIS_PW \
 --set twi.redis.port=$REDIS_PORT \
 --set twi.ingest.tags.ingest=$INGEST_TAG \
 --set twi.ingest.tags.ingested=$INGESTED_TAG \
 --set twi.pinboard.token=$PINBOARD_TOKEN \
 --set twi.twitter.client_key=${TWITTER_CLIENT_KEY} \
 --set twi.twitter.client_key_secret=${TWITTER_CLIENT_KEY_SECRET} \
 --set twi.ingest.feed.mappings=$INGEST_FEED_ENCODED_MAPPINGS \
 --set twi.ingest.twitter.mappings=$INGEST_TWITTER_ENCODED_MAPPINGS \
 --namespace $NS  \
 $CHART_NAME this-week-in-charts/twi-helm-chart   

kubectl create job --from=cronjob/${NS}-twi-twitter-ingest-cronjob ${NS}-twi-twitter-ingest-cronjob-${RANDOM} -n $NS 
kubectl create job --from=cronjob/${NS}-twi-bookmark-ingest-cronjob ${NS}-twi-bookmark-ingest-cronjob-${RANDOM} -n $NS 
kubectl create job --from=cronjob/${NS}-twi-feed-ingest-cronjob ${NS}-twi-feed-ingest-cronjob-${RANDOM} -n $NS 
