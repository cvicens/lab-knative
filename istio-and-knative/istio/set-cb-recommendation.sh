#!/bin/bash

## ./set-cb-recommendation.sh $APPS_NAMESPACE

APPS_NAMESPACE=$1
ISTIO_LAB=istio-files

oc whoami

if [ $? -ne 0 ]
then
   echo "You must be logged in in the platform"
   exit 1
fi

echo ""
echo "*** Setting CB in recommendation v2 subset" 
read -s -n 1 key
oc apply -f $ISTIO_LAB/recommendation_cb_policy_version_v2_mtls.yml -n $APPS_NAMESPACE

