#!/bin/bash

## ./disable-recommendation-policies.sh $APPS_NAMESPACE

APPS_NAMESPACE=$1
ISTIO_LAB=istio-files

oc whoami

if [ $? -ne 0 ]
then
   echo "You must be logged in in the platform"
   exit 1
fi

echo ""
echo "*** Back to 70% 30% in recommendation service versions " 
read -s -n 1 key
oc apply -f $ISTIO_LAB/recommendation-v1_v2_mtls.yml -n $APPS_NAMESPACE
