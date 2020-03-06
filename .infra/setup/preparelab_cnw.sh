#!/bin/sh
MYDIR="$( cd "$(dirname "$0")" ; pwd -P )"
function usage() {
    echo "usage: $(basename $0) [-p/--playbook -c/--count usercount -n/--namespace infra-namespace -s/--serverless]"
}

# Defaults
PLAYBOOK=provision.yml
USER_COUNT=10
INFRA_NAMESPACE="lab-infra"
SERVERLESS_NAMESPACE="lab-serverless"

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -p|--playbook)
    PLAYBOOK="$2"
    shift # past argument
    shift # past value
    ;;
    -c|--count)
    USER_COUNT="$2"
    shift # past argument
    shift # past value
    ;;
    -n|--namespace)
    INFRA_NAMESPACE="$2"
    shift # past argument
    shift # past value
    ;;
    -s|--serverless)
    SERVERLESS_NAMESPACE="$2"
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

#export ROLES_PATH=$(pwd)/roles
#printf "[defaults]\nroles_path = ${ROLES_PATH}" > ansible.cfg
#export ANSIBLE_CONFIG=./ansible.cfg

ansible-playbook -vvv playbooks/${PLAYBOOK} \
    -e infra_namespace=${INFRA_NAMESPACE} \
    -e serverless_namespace=${SERVERLESS_NAMESPACE} \
    -e openshift_token=$(oc whoami -t) \
    -e openshift_master_url=$(oc whoami --show-server) \
    -e openshift_user_password='openshift' \
    -e labs_project_suffix='-XX' \
    -e labs_github_account=redhat-developer-adoption-emea \
    -e labs_github_repo=cloud-native-guides \
    -e labs_github_ref=ocp-3.10 \
    -e labs_guide_name=${GUIDE_NAME} \
    -e user_count=${USER_COUNT}