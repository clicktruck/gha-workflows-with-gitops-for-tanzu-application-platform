#!/usr/bin/env bash
set -eo pipefail

# Teardown an existing management cluster

## Do not change anything below unless you know what you're doing!

if [ -z "$1" ]; then
	echo "Usage: teardown-tkg-management-cluster.sh {base64-encoded-management-cluster-kubeconfig-contents}"
	exit 1
fi

mkdir -p /tmp/.kube-tkg
echo "$1" | base64 -d > /tmp/.kube-tkg/config
chmod 600 /tmp/.kube-tkg/config

cluster_name=$(cat /tmp/.kube-tkg/config | yq '.clusters[].name')
echo "- Management cluster name is [ $cluster_name ]"

echo "- Logging in to management cluster"
tanzu login --kubeconfig /tmp/.kube-tkg/config --context ${cluster_name}-admin@${cluster_name} --name ${cluster_name}

echo "-- Tearing down management cluster $cluster_name"

tanzu management-cluster delete ${cluster_name} --use-existing-cleanup-cluster --yes --verbose 6
