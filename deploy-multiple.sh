#!/bin/sh

MYDIR="$( cd "$(dirname "$0")" ; pwd -P )"
function usage() {
    echo "usage: $(basename $0) [-c/--count usercount -n/--namespace base-namespace -s/--api-server api-server --start 1 --end usercount]"
}

# Defaults
QUAY_USERNAME=cvicensa
START=1

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -c|--count)
    USER_COUNT="$2"
    shift # past argument
    shift # past value
    ;;
    -n|--namespace)
    BASE_NAMESPACE="$2"
    shift # past argument
    shift # past value
    ;;
    -s|--api-server)
    API_SERVER="$2"
    shift # past argument
    shift # past value
    ;;
    -s|--api-server)
    API_SERVER="$2"
    shift # past argument
    shift # past value
    ;;
    --start)
    START="$2"
    shift # past argument
    shift # past value
    ;;
    --end)
    END="$2"
    shift # past argument
    shift # past value
    ;;
    *)    # unknown option
    echo "Unknown option: $key"
    usage
    exit 1
    ;;
esac
done

if [ -z "$USER_COUNT" ]
then
  echo "-c/--count cannot be empty"
  usage
  exit 1;
fi

if [ -z "$API_SERVER" ]
then
  echo "-s/--api-server cannot be empty"
  usage
  exit 1;
fi

if [ -z "$END" ]
then
  END=${USER_COUNT}
fi

# Install infra
$(cd .infra ./run-installer-job.sh)

# Load settings
. .workshop/settings.sh

WORKSHOP_IMAGE=${REGISTRY}/${WORKSHOP_NAME}:${WORKSHOP_VERSION}

TOKEN=$(oc whoami -t)

# Create lab cluster role to allow patching namespaces
oc apply -f .workshop/lab-user-role.yaml
    
for i in $(seq $START $END); 
do 
  oc adm policy add-cluster-role-to-user ${WORKSHOP_NAME}-user user$i
done

for i in $(seq $START $END); 
do 
  echo ">>>>> deploying lab ${WORKSHOP_NAME} for user$i"
  PROJECT_NAME=${WORKSHOP_NAME}-$i
  OCP_USERNAME=user$i
  OCP_PASSWORD=openshift
  oc login -u user$i -p openshift --server=${API_SERVER}
  oc new-project ${PROJECT_NAME}
  .workshop/scripts/deploy-personal.sh --override WORKSHOP_IMAGE=${WORKSHOP_IMAGE} \
    --override PROJECT_NAME=${PROJECT_NAME} --override OCP_USERNAME=${OCP_USERNAME} \
    --override OCP_PASSWORD=${OCP_PASSWORD} --override USERID=$i
  oc rollout pause dc/${WORKSHOP_NAME} -n ${PROJECT_NAME}
  oc set env dc/${WORKSHOP_NAME} STORAGE=/data USERID=$i OCP_USERNAME=${OCP_USERNAME} OCP_PASSWORD=${OCP_PASSWORD}
  oc rollout resume dc/${WORKSHOP_NAME} -n ${PROJECT_NAME}
  echo "<<<<< deploying lab ${WORKSHOP_NAME} for user$i"
done

oc login --token=${TOKEN}
