#!/bin/bash

## deploy-recommendation-v2.sh $APPS_NAMESPACE

APPS_NAMESPACE=$1
ISTIO_LAB=istio-files

oc whoami

if [ $? -ne 0 ]
then
   echo "You must be logged in in the platform"
   exit 1
fi

echo ""
echo "*** Deploying recommendation v2 service" 
read -s -n 1 key
oc new-app -l app=recommendation,version=v2 --name=recommendation-v2 --docker-image=quay.io/dsanchor/recommendation:vertx -e JAVA_OPTIONS='-Xms512m -Xmx512m -Djava.net.preferIPv4Stack=true' -e VERSION=v2 -n $APPS_NAMESPACE

oc patch dc/recommendation-v2 -p '{"spec":{"template":{"metadata":{"annotations":{"sidecar.istio.io/inject":"true"}}}}}' -n $APPS_NAMESPACE

oc delete svc/recommendation-v2 -n $APPS_NAMESPACE
