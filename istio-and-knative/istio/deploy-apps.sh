#!/bin/bash

## ./deploy-apps.sh $APPS_NAMESPACE $SUBDOMAIN

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
echo "*** Creating new project '$APPS_NAMESPACE' in OCP" 
read -s -n 1 key
oc new-project $APPS_NAMESPACE

echo ""
echo "*** Adding new project '$APPS_NAMESPACE' to the service mesh tenant control (we run istio control plane in istio-system project)"
read -s -n 1 key
oc patch servicemeshmemberroll default --type='json' -p='[{"op": "add", "path": "/spec/members/-", "value": "'${APPS_NAMESPACE}'"}]' -n istio-system

echo ""
echo "*** Deploying customer v1 service" 
read -s -n 1 key
oc new-app -l app=customer,version=v1 --name=customer-v1 --docker-image=quay.io/dsanchor/customer:quarkus -e JAEGER_ENDPOINT=http://jaeger-collector.istio-system.svc:14268/api/traces -e  JAEGER_PROPAGATION=b3 -e  JAEGER_SAMPLER_TYPE=const -e  JAEGER_SAMPLER_PARAM=1 -e  JAVA_OPTIONS='-Xms512m -Xmx512m -Djava.net.preferIPv4Stack=true' -n $APPS_NAMESPACE

oc delete svc/customer-v1 -n $APPS_NAMESPACE
oc create -f $ISTIO_LAB/customer/kubernetes/Service.yml -n $APPS_NAMESPACE

echo "*** Applying auto sidecar injection in customer v1 service" 
read -s -n 1 key
oc patch dc/customer-v1 -p '{"spec":{"template":{"metadata":{"annotations":{"sidecar.istio.io/inject":"true"}}}}}' -n $APPS_NAMESPACE

echo ""
echo "*** Deploying preference v1 service" 
read -s -n 1 key
oc new-app -l app=preference,version=v1 --name=preference-v1 --docker-image=quay.io/dsanchor/preference:quarkus -e JAEGER_SERVICE_NAME=preference -e  JAEGER_REPORTER_LOG_SPANS=true -e  JAEGER_SAMPLER_TYPE=const -e JAEGER_SAMPLER_PARAM=1 -e JAVA_OPTIONS='-Xms512m -Xmx512m -Djava.net.preferIPv4Stack=true'  -n $APPS_NAMESPACE


oc patch dc/preference-v1 -p '{"spec":{"template":{"metadata":{"annotations":{"sidecar.istio.io/inject":"true"}}}}}' -n $APPS_NAMESPACE

oc delete svc/preference-v1 -n $APPS_NAMESPACE
oc create -f $ISTIO_LAB/preference/kubernetes/Service.yml -n $APPS_NAMESPACE

echo ""
echo "*** Deploying recommendation v1 service" 
read -s -n 1 key
oc new-app -l app=recommendation,version=v1 --name=recommendation-v1 --docker-image=quay.io/dsanchor/recommendation:vertx -e JAVA_OPTIONS='-Xms512m -Xmx512m -Djava.net.preferIPv4Stack=true' -e VERSION=v1 -n $APPS_NAMESPACE

oc patch dc/recommendation-v1 -p '{"spec":{"template":{"metadata":{"annotations":{"sidecar.istio.io/inject":"true"}}}}}' -n $APPS_NAMESPACE

oc delete svc/recommendation-v1 -n $APPS_NAMESPACE
oc create -f $ISTIO_LAB/recommendation/kubernetes/Service.yml -n $APPS_NAMESPACE

echo ""
echo "*** Deploying partner v1 service" 
read -s -n 1 key
oc new-app -l app=partner,version=v1 --name=partner-v1 --docker-image=quay.io/dsanchor/partner:sb -e JAEGER_SERVICE_NAME=partner -e JAEGER_ENDPOINT=http://jaeger-collector.istio-system.svc:14268/api/traces -e JAEGER_PROPAGATION=b3 -e JAEGER_SAMPLER_TYPE=const -e JAEGER_SAMPLER_PARAM=1 -e JAVA_OPTIONS='-Xms512m -Xmx512m -Djava.net.preferIPv4Stack=true' -n $APPS_NAMESPACE

oc delete svc/partner-v1 -n $APPS_NAMESPACE
oc create -f $ISTIO_LAB/partner/kubernetes/Service.yml -n $APPS_NAMESPACE

oc patch dc/partner-v1 -p '{"spec":{"template":{"metadata":{"annotations":{"sidecar.istio.io/inject":"true"}}}}}' -n $APPS_NAMESPACE

echo ""
echo "*** Adding ingress and basic Istio routing for customer and partner services" 
read -s -n 1 key
cat $ISTIO_LAB/customer-ingress_mtls.yml | APP_SUBDOMAIN=$(echo $SUBDOMAIN) NAMESPACE=$(echo $APPS_NAMESPACE) envsubst | oc apply -f -
cat $ISTIO_LAB/partner-ingress_mtls.yml | APP_SUBDOMAIN=$(echo $SUBDOMAIN) NAMESPACE=$(echo $APPS_NAMESPACE) envsubst | oc apply -f -
echo ""

echo ""
echo " **************************************************************************************************************************** "
echo ""
echo "    Test customer service: curl -v customer-$APPS_NAMESPACE-istio-system.$SUBDOMAIN                                              "
echo ""
echo "    Test partner service: curl -v partner-$APPS_NAMESPACE-istio-system.$SUBDOMAIN                                                "
echo ""
echo " **************************************************************************************************************************** "
echo ""
