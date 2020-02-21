#!/bin/bash

## ./set-level2-service-accounts.sh $APPS_NAMESPACE

APPS_NAMESPACE=$1
ISTIO_LAB=istio-files

oc whoami

if [ $? -ne 0 ]
then
   echo "You must be logged in in the platform"
   exit 1
fi

echo ""
echo "*** Changing from default to level2 service account in preference" 
read -s -n 1 key
oc patch dc/preference-v1 -p '{"spec":{"template":{"spec":{"serviceAccount":"level2"}}}}}' -n $APPS_NAMESPACE


