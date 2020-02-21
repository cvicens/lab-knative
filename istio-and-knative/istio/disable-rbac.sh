#!/bin/bash

## ./disable-rbac.sh

APPS_NAMESPACE=$1
ISTIO_LAB=istio-files

oc whoami

if [ $? -ne 0 ]
then
   echo "You must be logged in in the platform"
   exit 1
fi

echo ""
echo "*** Disabling RBAC for service mesh" 
read -s -n 1 key
oc delete -f  $ISTIO_LAB/rbac-mesh.yml

