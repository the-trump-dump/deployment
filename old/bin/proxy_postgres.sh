#!/usr/bin/env bash

kubectl port-forward $( kubectl get pods | grep postgres | cut -f1 -d\ ) 5432 