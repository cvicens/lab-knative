LAB - Markdown Sample
=====================

Sample workshop content using Markdown formatting for pages.


## Preparing the workshop

oc new-project lab-knative

DASHBOARD_IMAGE in .workshop/default-settings.sh ==> Dokerfile !

WORKSHOP_NAME => .workshop/settings.sh

WORKSHOP_TITLE       => .workshop/settings.sh
WORKSHOP_DESCRIPTION => .workshop/settings.sh
SPAWNER_REPO         => .workshop/settings.sh

AUTH_USERNAME => .workshop/develop-settings.sh
AUTH_PASSWORD => .workshop/develop-settings.sh

Update Workshop Scripts => git submodule update --remote

## Deploying the workshop
./deploy-multiple.sh -c 10 --start 1 --end 10  -s https://${API_SERVER}
./deploy-multiple.sh -c 1 --start 10 --end 10  -s https://api.cluster-gramola-ac20.gramola-ac20.example.opentlc.com:6443

## Local Development
./image-build.sh
docker run --rm -p 10080:10080 -e CLUSTER_SUBDOMAIN=apps.cluster-kharon-ba75.kharon-ba75.example.opentlc.com -e OCP_USERNAME=user1 -e USERID=1 -e OCP_PASSWORD=openshift -e KUBERNETES_SERVICE_HOST=api.cluster-kharon-ba75.kharon-ba75.example.opentlc.com -e KUBERNETES_SERVICE_PORT=6443 --name lab-knative lab-knative:0.2
