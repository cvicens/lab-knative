#!/bin/bash

## set-random-errors.sh $APPS_NAMESPACE

APPS_NAMESPACE=$1
ISTIO_LAB=istio-files

oc whoami

if [ $? -ne 0 ]
then
   echo "You must be logged in in the platform"
   exit 1
fi

echo ""
echo "*** Applying 70% of HTTP 500 errors " 
read -s -n 1 key
oc apply -f $ISTIO_LAB/recommendation-fault.yml -n $APPS_NAMESPACE
