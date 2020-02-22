. .workshop/settings.sh

API_SERVER=https://api.cluster-kharon-ba75.kharon-ba75.example.opentlc.com:6443

QUAY_USERNAME=cvicensa

WORKSHOP_IMAGE=quay.io/${QUAY_USERNAME}/${WORKSHOP_NAME}:0.2

#docker build -t ${WORKSHOP_IMAGE} .
#docker push ${WORKSHOP_IMAGE}

END=2

for i in $(seq 1 $END); 
do 
    echo ">>>>> deploying for user$i"
    PROJECT_NAME=lab-knative-$i
    OCP_USERNAME=user$i
    OCP_PASSWORD=openshift
    oc login -u user$i -p openshift --server=${API_SERVER}
    oc new-project ${PROJECT_NAME}
    .workshop/scripts/deploy-personal.sh --override WORKSHOP_IMAGE=${WORKSHOP_IMAGE} \
      --override PROJECT_NAME=${PROJECT_NAME} --override OCP_USERNAME=${OCP_USERNAME} \
      --override OCP_PASSWORD=${OCP_PASSWORD} --override USERID=$i
    echo "<<<<< deploying for user$i"
done


