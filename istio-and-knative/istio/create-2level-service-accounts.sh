#!/bin/bash

## create-2level-service-accounts.sh $APPS_NAMESPACE

APPS_NAMESPACE=$1
ISTIO_LAB=istio-files

oc whoami

if [ $? -ne 0 ]
then
   echo "You must be logged in in the platform"
   exit 1
fi

echo ""
echo "*** Creating level1 and level2 service accounts" 
read -s -n 1 key
for serviceAccount in level1 level2; do           
   oc create serviceaccount ${serviceAccount} -n $APPS_NAMESPACE
done	
