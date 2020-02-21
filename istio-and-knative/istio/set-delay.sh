#!/bin/bash

## ./set-delay.sh $APPS_NAMESPACE 

APPS_NAMESPACE=$1
ISTIO_LAB=istio-files

oc whoami

if [ $? -ne 0 ]
then
   echo "You must be logged in in the platform"
   exit 1
fi

echo ""
echo "*** Applying 3s delay in 50% of calls to recommendation service" 
read -s -n 1 key
cat  $ISTIO_LAB/recommendation-delay.yml | DELAY=3s PERCENT=50 envsubst | oc apply -f - -n $APPS_NAMESPACE
