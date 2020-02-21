#!/bin/bash

## ./set-timeout.sh $APPS_NAMESPACE 

APPS_NAMESPACE=$1
ISTIO_LAB=istio-files

oc whoami

if [ $? -ne 0 ]
then
   echo "You must be logged in in the platform"
   exit 1
fi

echo ""
echo "*** Applying 2s timeout for preference service" 
read -s -n 1 key
oc apply -f $ISTIO_LAB/preference-timeout_mtls.yml -n $APPS_NAMESPACE

