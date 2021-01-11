#!/usr/bin/env bash

## basically this will trigger a refresh in prod unless you opt in to the development env 
THE_ENV=""
if [ "${1}" = "" ] ; then 
 THE_ENV=""
else 
 THE_ENV="${1}."
fi 

URI_ROOT=https://api.${THE_ENV}bootifulpodcast.fm
echo "contacting $URI_ROOT"
TOKEN=$(curl -XPOST -u jlong ${URI_ROOT}/token ) 
curl -H"Authorization: bearer $TOKEN " -XDELETE ${URI_ROOT}/admin/caches 