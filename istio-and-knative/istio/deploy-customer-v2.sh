#!/bin/bash

## deploy-customer-v2.sh $APPS_NAMESPACE

APPS_NAMESPACE=$1
ISTIO_LAB=istio-files

oc whoami

if [ $? -ne 0 ]
then
   echo "You must be logged in in the platform"
   exit 1
fi

echo ""
echo "*** Deploying customer v2 service" 
read -s -n 1 key
oc new-app -l app=customer,version=v2 --name=customer-v2 --docker-image=quay.io/dsanchor/customer:quarkus -e JAEGER_ENDPOINT=http://jaeger-collector.istio-system.svc:14268/api/traces -e  JAEGER_PROPAGATION=b3 -e  JAEGER_SAMPLER_TYPE=const -e  JAEGER_SAMPLER_PARAM=1 -e  JAVA_OPTIONS='-Xms512m -Xmx512m -Djava.net.preferIPv4Stack=true' -n $APPS_NAMESPACE

oc patch dc/customer-v2 -p '{"spec":{"template":{"metadata":{"annotations":{"sidecar.istio.io/inject":"true"}}}}}' -n $APPS_NAMESPACE

oc delete svc/customer-v2 -n $APPS_NAMESPACE
