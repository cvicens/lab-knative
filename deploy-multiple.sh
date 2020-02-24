. .workshop/settings.sh

API_SERVER=https://api.cluster-kharon-ba75.kharon-ba75.example.opentlc.com:6443

QUAY_USERNAME=cvicensa

WORKSHOP_IMAGE=quay.io/${QUAY_USERNAME}/${WORKSHOP_NAME}:0.2

docker build -t ${WORKSHOP_IMAGE} .
docker push ${WORKSHOP_IMAGE}

TOKEN=$(oc whoami -t)

# Create lab cluster role to allow patching namespaces
oc apply -f .workshop/lab-user-role.yaml
    
START=2
END=30

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
  echo "<<<<< deploying flab ${WORKSHOP_NAME} for user$i"
done

oc login --token=${TOKEN}