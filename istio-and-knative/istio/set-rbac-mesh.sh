#!/bin/bash

## ./set-rbac-mesh.sh

ISTIO_LAB=istio-files

oc whoami

if [ $? -ne 0 ]
then
   echo "You must be logged in in the platform"
   exit 1
fi

echo ""
echo "*** Setting RBAC in mesh" 
read -s -n 1 key
oc apply -f  $ISTIO_LAB/rbac-mesh.yml

