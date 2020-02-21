#!/bin/bash

## ./disable-temporal-rbac-access.sh $APPS_NAMESPACE

APPS_NAMESPACE=$1
ISTIO_LAB=istio-files

oc whoami

if [ $? -ne 0 ]
then
   echo "You must be logged in in the platform"
   exit 1
fi

echo ""
echo "*** Removing admin role and bindings" 
read -s -n 1 key
cat $ISTIO_LAB/admin-tmp-access.yml | NAMESPACE=$(echo $APPS_NAMESPACE) envsubst | oc delete -f -
