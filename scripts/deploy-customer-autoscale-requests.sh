#!/bin/bash

## ./deploy-customer-autoscale-requests.sh $APPS_NAMESPACE $SUBDOMAIN

APPS_NAMESPACE=$1
SUBDOMAIN=$2
SCRIPTS_DIR=$(dirname $0)/descriptors

oc whoami

if [ $? -ne 0 ]
then
   echo "You must be logged in in the platform"
   exit 1
fi


echo ""
echo "*** Deploying customer kservice with autoscale (10 concurrent request per pod: from 1 to 10 pods)" 
cat $SCRIPTS_DIR/customer-autoscale-requests.yml | NAMESPACE=$(echo $APPS_NAMESPACE) envsubst | oc apply -f - -n $APPS_NAMESPACE

echo ""
echo " **************************************************************************************************************************** "
echo ""
echo "    Test customer service: hey -c 100 -z 20s http://customer.$APPS_NAMESPACE.$SUBDOMAIN                                                      "
echo ""
echo " **************************************************************************************************************************** "
echo ""
