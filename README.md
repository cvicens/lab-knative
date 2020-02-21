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



## Local Development
docker build -t lab-knative .
docker run --rm -p 10080:10080 lab-knative
