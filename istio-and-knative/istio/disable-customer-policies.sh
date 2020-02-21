#!/bin/bash

## ./disable-customer-policies.sh $APPS_NAMESPACE $SUBDOMAIN

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
echo "*** Back to customer v1" 
read -s -n 1 key
cat $ISTIO_LAB/customer-ingress_mtls.yml | APP_SUBDOMAIN=$(echo $SUBDOMAIN) NAMESPACE=$(echo $APPS_NAMESPACE) envsubst | oc apply -f -
