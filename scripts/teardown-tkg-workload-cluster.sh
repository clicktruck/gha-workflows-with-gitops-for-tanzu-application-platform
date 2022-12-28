#!/usr/bin/env bash
set -eo pipefail

# Teardown an existing workload cluster

## Do not change anything below unless you know what you're doing!

if [ -z "$1" ] && [ -z "$2" ]; then
	echo "Usage: teardown-tkg-workload-cluster.sh {workload-cluster-name} {base64-encoded-management-cluster-kubeconfig-contents}"
	exit 1
fi

WORKLOAD_CLUSTER_NAME="$1"

echo "- Decoding the management cluster's KUBECONFIG contents and saving output to /tmp/.kube-tkg/config"
mkdir -p /tmp/.kube-tkg
echo "$2" | base64 -d > /tmp/.kube-tkg/config
chmod 600 /tmp/.kube-tkg/config

echo "- Logging in to management cluster"
cluster_name=$(cat /tmp/.kube-tkg/config | yq '.clusters[].name')
tanzu login --kubeconfig /tmp/.kube-tkg/config --context ${cluster_name}-admin@${cluster_name} --name ${cluster_name}

echo "- Setting current context to management cluster"
tanzu management-cluster kubeconfig get ${cluster_name} --admin
kubectl config use-context ${cluster_name}-admin@${cluster_name}

echo "-- Tearing down workload cluster $WORKLOAD_CLUSTER_NAME"

IS_KAPP_MANAGED="$3"
if [ -z "$IS_KAPP_MANAGED" ];then
  tanzu cluster delete $WORKLOAD_CLUSTER_NAME --yes --verbose 6
else
  kapp delete --app $WORKLOAD_CLUSTER_NAME --yes
fi