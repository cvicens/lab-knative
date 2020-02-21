#!/bin/bash

## ./set-traffic-mirror.sh $APPS_NAMESPACE $SUBDOMAIN

APPS_NAMESPACE=$1
SUBDOMAIN=$2
ISTIO_LAB=istio-files

oc whoami

if [ $? -ne 0 ]
then
   echo "You must be logged in in the platform"
   exit 1
fi

echo ""
echo "*** Set traffic mirror from customer v1 to customer v2" 
read -s -n 1 key
cat $ISTIO_LAB/customer-mirror-from-v1-to-v2_mtls.yml | APP_SUBDOMAIN=$(echo $SUBDOMAIN) NAMESPACE=$(echo $APPS_NAMESPACE) envsubst | oc apply -f - 
