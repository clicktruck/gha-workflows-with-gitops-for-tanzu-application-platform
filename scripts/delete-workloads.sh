#!/usr/bin/env bash
set -eo pipefail

## Deletes workloads from one or more namespaces using tanzu CLI

## Do not change anything below unless you know what you're doing!

if [ "x${KUBECONFIG}" == "x" ]; then
  echo "Workload cluster KUBECONFIG environment variable not set."

  if [ -z "$1" ]; then
    echo "Workload cluster name was not supplied!"
	  exit 1
  fi

  if [ -z "$2" ]; then
    echo "Management cluster's KUBECONFIG base64-encoded contents was not supplied!"
	  exit 1
  fi

  WORKLOAD_CLUSTER_NAME="$1"

  echo "- Decoding the management cluster's KUBECONFIG contents and saving output to /tmp/.kube-tkg/config"
  mkdir -p /tmp/.kube-tkg
  echo "$2" | base64 -d > /tmp/.kube-tkg/config
  chmod 600 /tmp/.kube-tkg/config

  cluster_name=$(cat /tmp/.kube-tkg/config | yq '.clusters[].name')
  echo "- Management cluster name is [ $cluster_name ]"

  echo "- Logging in to management cluster"
  tanzu login --kubeconfig /tmp/.kube-tkg/config --context ${cluster_name}-admin@${cluster_name} --name ${cluster_name}

  echo "- Obtaining the workload cluster's KUBECONFIG and setting the current context for kubectl"
  tanzu cluster kubeconfig get ${WORKLOAD_CLUSTER_NAME} --admin
  kubectl config use-context ${WORKLOAD_CLUSTER_NAME}-admin@${WORKLOAD_CLUSTER_NAME}

  if [ -z "$3" ]; then
    echo "Namespaces were not supplied!"
    exit 1

  else
    namespaces="$3"
    IFS=',' read -ra ns_array <<< "$namespaces"
    for ns in "${ns_array[@]}"
    do
      echo "Does namespace exist?"
      kubectl get namespace $ns
      echo "Are there any workloads and/or deliverables in namespace [ $ns ]?"
      kubectl get workload,deliverable --namespace $ns
      echo "Attempting to delete workloads in namespace [ $ns ]..."
      tanzu apps workload delete --all --namespace $ns --yes
    done
  fi

else
  echo "Workload cluster KUBECONFIG environment variable was set."

  if [ -z "$1" ]; then
    echo "Namespaces were not supplied!"
    exit 1

  else
    namespaces="$1"
    IFS=',' read -ra ns_array <<< "$namespaces"
    for ns in "${ns_array[@]}"
    do
      echo "Does namespace exist?"
      kubectl get namespace $ns
      echo "Are there any workloads and/or deliverables in namespace [ $ns ]?"
      kubectl get workload,deliverable --namespace $ns
      echo "Attempting to delete workloads in namespace [ $ns ]..."
      tanzu apps workload delete --all --namespace $ns --yes
    done
  fi

fi
