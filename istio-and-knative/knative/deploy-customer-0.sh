#!/bin/bash

## ./deploy-customer-0.sh $APPS_NAMESPACE $SUBDOMAIN

APPS_NAMESPACE=$1
SUBDOMAIN=$2
KNATIVE_LAB=knative-files

oc whoami

if [ $? -ne 0 ]
then
   echo "You must be logged in in the platform"
   exit 1
fi


echo ""
echo "*** Deploying customer kservice (defaults)" 
read -s -n 1 key
cat $KNATIVE_LAB/customer-0.yml | NAMESPACE=$(echo $APPS_NAMESPACE) envsubst | oc apply -f - -n $APPS_NAMESPACE

echo ""
echo " **************************************************************************************************************************** "
echo ""
echo "    Test customer service: curl -v customer.$APPS_NAMESPACE.$SUBDOMAIN                                                      "
echo ""
echo " **************************************************************************************************************************** "
echo ""
