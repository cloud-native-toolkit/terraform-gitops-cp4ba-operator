#!/usr/bin/env bash
echo "*****  Starting Validate-deploy.sh  **************"
GIT_REPO=$(cat git_repo)
GIT_TOKEN=$(cat git_token)

export KUBECONFIG=$(cat .kubeconfig)
echo "KUBE CONFIG ${KUBECONFIG}"
PVCNAME1="cp4a-shared-log-pvc"
PVCNAME2="operator-shared-pvc"

NAMESPACE=$(cat .namespace)
##getting file not found for gitops-output.json so hard coding values
#COMPONENT_NAME=$(jq -r '.name // "iaf-operator"' gitops-output.json)
COMPONENT_NAME="cp4ba-operator"
#BRANCH=$(jq -r '.branch // "main"' gitops-output.json)
BRANCH="dev-branch"

#SERVER_NAME=$(jq -r '.server_name // "default"' gitops-output.json)
SERVER_NAME="default"
#LAYER=$(jq -r '.layer_dir // "2-services"' gitops-output.json)
LAYER="2-services"

#TYPE=$(jq -r '.type // "base"' gitops-output.json)
TYPE="base"

mkdir -p .testrepo
echo "NOW TRYING TO CLONE TO THE TEST REPO"
git clone https://${GIT_TOKEN}@${GIT_REPO} .testrepo

cd .testrepo || exit 1

find . -name "*"
### CHeck for the yaml files are copied to the repo
if [[ ! -f "argocd/${LAYER}/cluster/${SERVER_NAME}/${TYPE}/${NAMESPACE}-${COMPONENT_NAME}.yaml" ]]; then
  echo "ArgoCD config missing - argocd/${LAYER}/cluster/${SERVER_NAME}/${TYPE}/${NAMESPACE}-${COMPONENT_NAME}.yaml"
  exit 1
fi

echo "Printing argocd/${LAYER}/cluster/${SERVER_NAME}/${TYPE}/${NAMESPACE}-${COMPONENT_NAME}.yaml"
cat "argocd/${LAYER}/cluster/${SERVER_NAME}/${TYPE}/${NAMESPACE}-${COMPONENT_NAME}.yaml"


count=0
until kubectl get namespace "${NAMESPACE}" 1> /dev/null 2> /dev/null || [[ $count -eq 20 ]]; do
  echo "Waiting for namespace: ${NAMESPACE}"
  count=$((count + 1))
  sleep 15
done

if [[ $count -eq 20 ]]; then
  echo "Timed out waiting for namespace: ${NAMESPACE}"
  exit 1
else
  echo "Found namespace: ${NAMESPACE}. Sleeping for 30 seconds to wait for everything to settle down"
  sleep 30
fi
## Check if the subscription for ibm-automation is there 
SUBSNAME="ibm-automation"
count=0
#until kubectl get subs "${SUBSNAME}" -n "${NAMESPACE}" || [[ $count -eq 20 ]]; do
until kubectl get subs -n "${NAMESPACE}" |grep "${SUBSNAME}" || [[ $count -eq 20 ]]; do
  echo "Waiting for Subscription/${SUBSNAME} in ${NAMESPACE}"
  count=$((count + 1))
  sleep 15
done
count=0
if [[ $count -eq 20 ]]; then
  echo "Timed out waiting for Subscription/${SUBSNAME} in ${NAMESPACE}"
  kubectl get all -n "${NAMESPACE}"
  exit 1
fi

count=0
until kubectl get pvc "${PVCNAME1}" -n "${NAMESPACE}" || [[ $count -eq 20 ]]; do
  echo "Waiting for PVC/${PVCNAME1} in ${NAMESPACE} COUNTER $count" 
  count=$((count + 1))
  sleep 20
done
count=0
until kubectl get pvc "${PVCNAME2}" -n "${NAMESPACE}" || [[ $count -eq 20 ]]; do
  echo "Waiting for PVC/${PVCNAME2} in ${NAMESPACE} COUNTER $count" 
  count=$((count + 1))
  sleep 20
done
echo "After the PVC forcibly sleeping for 2 mins"
#sleep 120
#echo "After the PVC forcibly sleeping for 2 mins"
#sleep 120
echo "After the PVC forcibly sleeping for 2 mins"
#sleep 120

count=0
SUBSNAME="cp4a-operator"
until kubectl get csv -n "${NAMESPACE}" | grep "${SUBSNAME}" || [[ $count -eq 20 ]]; do
  echo "Waiting for Subscription/${SUBSNAME} in ${NAMESPACE} counter=$count"
  count=$((count + 1))
  sleep 15
done

kubectl get subscription "${SUBSNAME}" -n "${NAMESPACE}" || exit 1  

cd ..
#Temporarily commented the remove repo
#rm -rf .testrepo 