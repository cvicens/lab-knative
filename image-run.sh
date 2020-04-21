#!/bin/sh

. .workshop/settings.sh

MYDIR="$( cd "$(dirname "$0")" ; pwd -P )"
function usage() {
    echo "usage: $(basename $0) [-s/--api-server api-server -b/--app-base apps.xzy.com -u/--userid]"
}

# Defaults

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -s|--api-server)
    API_SERVER="$2"
    API_SERVER_HOST=$(echo ${API_SERVER} | awk -F ":" '{print $1}')
    API_SERVER_PORT=$(echo ${API_SERVER} | awk -F ":" '{print $2}')
    shift # past argument
    shift # past value
    ;;
    -b|--app-base)
    APP_BASE="$2"
    shift # past argument
    shift # past value
    ;;
    -u|--userid)
    USERID="$2"
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

if [ -z "$API_SERVER_HOST" ] || [ -z "$API_SERVER_PORT" ]
then
  echo "-s|--api-server cannot be empty"
  usage
  exit 1;
fi

if [ -z "$APP_BASE" ]
then
  echo "-b|--app-base cannot be empty"
  usage
  exit 1;
fi

if [ -z "$USERID" ]
then
  echo "-u|--userid cannot be empty"
  usage
  exit 1;
fi

docker run --rm -p 10080:10080 -e CLUSTER_SUBDOMAIN=${APP_BASE} \
  -e OCP_USERNAME="user${USERID}" -e USERID="${USERID}" -e OCP_PASSWORD=openshift \
  -e KUBERNETES_SERVICE_HOST=${API_SERVER_HOST} \
  -e KUBERNETES_SERVICE_PORT=${API_SERVER_PORT} --name ${WORKSHOP_NAME} ${WORKSHOP_NAME}:${WORKSHOP_VERSION}