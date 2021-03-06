#!/bin/bash

## ./deploy-all-services.sh $APPS_NAMESPACE $SUBDOMAIN

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
echo "*** Deploying all services " 
read -s -n 1 key
cat $KNATIVE_LAB/all-services.yml | NAMESPACE=$(echo $APPS_NAMESPACE) envsubst | oc apply -f - -n $APPS_NAMESPACE

echo ""
echo " **************************************************************************************************************************** "
echo ""
echo "    Test customer service: curl -v customer.$APPS_NAMESPACE.$SUBDOMAIN                                                      "
echo ""
echo " **************************************************************************************************************************** "
echo ""
