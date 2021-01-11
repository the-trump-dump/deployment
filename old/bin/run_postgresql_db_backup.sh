#!/usr/bin/env bash

set -e

export BP_MODE_LOWERCASE=${BP_MODE_LOWERCASE:-development}

echo "Manually starting an instance of the backup-cronjob"
JOB_ID=backup-cronjob-initial-run-job
kubectl get jobs -n $BP_MODE_LOWERCASE | grep $JOB_ID && kubectl delete  jobs/$JOB_ID  -n $BP_MODE_LOWERCASE
kubectl create job --from=cronjob/backup-cronjob $JOB_ID  -n $BP_MODE_LOWERCASE