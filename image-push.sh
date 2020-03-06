#!/bin/sh

. .workshop/settings.sh

WORKSHOP_IMAGE=${REGISTRY}/${WORKSHOP_NAME}:${WORKSHOP_VERSION}

docker push ${WORKSHOP_IMAGE}