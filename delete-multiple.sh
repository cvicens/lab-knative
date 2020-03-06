. .workshop/settings.sh

API_SERVER=https://api.cluster-lisbon-5342.lisbon-5342.example.opentlc.com:6443

START=1
END=1

for i in $(seq $START $END); 
do 
  echo ">>>>> deleting lab ${WORKSHOP_NAME} for user$i"
  PROJECT_NAME=${WORKSHOP_NAME}-$i
  oc delete project ${PROJECT_NAME}
  oc delete project labs-$i
  echo "<<<<< deleting lab ${WORKSHOP_NAME} for user$i"
done
