#!/bin/bash

## ./set-level1-service-accounts.sh $APPS_NAMESPACE

APPS_NAMESPACE=$1
ISTIO_LAB=istio-files

oc whoami

if [ $? -ne 0 ]
then
   echo "You must be logged in in the platform"
   exit 1
fi

echo ""
echo "*** Changing from default to level1 service account in customer and partner services" 
read -s -n 1 key
oc patch dc/customer-v1 -p '{"spec":{"template":{"spec":{"serviceAccount":"level1"}}}}}' -n $APPS_NAMESPACE
oc patch dc/customer-v2 -p '{"spec":{"template":{"spec":{"serviceAccount":"level1"}}}}}' -n $APPS_NAMESPACE
oc patch dc/partner-v1 -p '{"spec":{"template":{"spec":{"serviceAccount":"level1"}}}}}' -n $APPS_NAMESPACE

