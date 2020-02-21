#!/bin/bash

## ./set-canary-customer.sh $APPS_NAMESPACE $SUBDOMAIN

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
echo "*** Adding canary to customer service" 
read -s -n 1 key
cat $ISTIO_LAB/customer-user-header_mtls.yml | APP_SUBDOMAIN=$(echo $SUBDOMAIN) NAMESPACE=$(echo $APPS_NAMESPACE) envsubst | oc apply -f - 
echo ""

echo ""
echo " **************************************************************************************************************************** "
echo ""
echo "    Test customer v2 service: watch -n2 \"curl -v -H 'user: david'   customer-$APPS_NAMESPACE-istio-system.$SUBDOMAIN\"     "
echo ""
echo "    Test customer v1 service: curl -v customer-$APPS_NAMESPACE-istio-system.$SUBDOMAIN                                       "
echo ""
echo " **************************************************************************************************************************** "
echo ""
