#!/bin/sh

TOKEN=$(oc whoami -t | base64)

NAMESPACE="lab-knative-installer"

if [ -z "${TOKEN}" ]
then
    echo "You have to log in in your OCP cluster ;-)"
    exit 1
fi

oc new-project ${NAMESPACE}

oc apply -n ${NAMESPACE} -f ./lab-installer-role.yaml
oc apply -n ${NAMESPACE} -f ./lab-installer-service-account.yaml

cat ./lab-installer-role-binding.yaml | \
  sed "s/{{\s*NAMESPACE\s*}}/${NAMESPACE}/" | oc apply -n ${NAMESPACE} -f -

oc delete job lab-installer -n ${NAMESPACE} ;  oc apply -n ${NAMESPACE} -f ./lab-installer-batch.yaml