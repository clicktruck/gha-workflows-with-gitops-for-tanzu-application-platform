#!/usr/bin/env bash
set -eo pipefail

# Deploy a new TKG workload cluster

## Do not change anything below unless you know what you're doing!

if [ -z "$1" ]; then
	echo "Usage: deploy-tkg-workload-cluster.sh {gitops-directory} {new-base64-encoded-management-cluster-kubeconfig-contents} {existing-base64-encoded-management-cluster-kubeconfig-contents}"
	exit 1
fi

if [ -z "$GITHUB_WORKSPACE" ]; then
  GITOPS_DIR=../"$1"
else
  GITOPS_DIR=$GITHUB_WORKSPACE/$1
fi

if [ "$2" == "" ] && [ "$3" == "" ]; then
  echo "You must supply either new or existing base64 encoded TKG management cluster contents"
  exit 1
fi

echo "- Decoding the management cluster's KUBECONFIG contents and saving output to /tmp/.kube-tkg/config"
mkdir -p /tmp/.kube-tkg


if [ "$3" != "" ]; then
  echo "$3" | base64 -d > /tmp/.kube-tkg/config
fi

if [ "$2" != "" ]; then
  echo "$2" | base64 -d > /tmp/.kube-tkg/config
fi

chmod 600 /tmp/.kube-tkg/config

management_cluster_name=$(cat /tmp/.kube-tkg/config | yq '.clusters[].name')
echo "- Management cluster name is [ $management_cluster_name ]"

echo "- Logging in to management cluster"
tanzu login --kubeconfig /tmp/.kube-tkg/config --context ${management_cluster_name}-admin@${management_cluster_name} --name ${management_cluster_name}

echo "- Setting current context to management cluster"
export KUBECONFIG=/tmp/.kube-tkg/config

cd ${GITOPS_DIR}/.install

echo "-- Creating workload cluster with"
cat cluster.yml

workload_cluster_name=$(yq '.CLUSTER_NAME' cluster.yml)
echo "-- Workload cluster name is [ $workload_cluster_name ]"

if [ $(ls -1 *-overlay*.yml | wc -l) -gt 0 ] && [ $(yq '.KAPP_MANAGED' cluster.yml | wc -l) -eq 1 ]; then
  echo "-- Moving overlays into place"
  mkdir -p $HOME/.config/tanzu/tkg/providers/ytt/03_customizations/
  mv *-overlay*.yml $HOME/.config/tanzu/tkg/providers/ytt/03_customizations/
  tanzu cluster create --file cluster.yml --dry-run | kapp deploy --diff-changes --app $workload_cluster_name --yes --file -
else
  tanzu cluster create --file cluster.yml --verbose 6
fi
