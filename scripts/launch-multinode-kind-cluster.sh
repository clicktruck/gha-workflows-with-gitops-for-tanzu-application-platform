#!/usr/bin/env bash

# @see https://kind.sigs.k8s.io/docs/user/ingress/#create-cluster

export KIND_CLUSTER_NAME=kind-demo
export K8S_NODE_VERSION=kindest/node:v1.24.2@sha256:4616d7ad9e7104df2feb21c95ad3853e86da81c41b82187509c5bfb884ade819

startup() {
cat <<EOF | kind create cluster --name=$KIND_CLUSTER_NAME --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  image: $K8S_NODE_VERSION
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
- role: worker
  image: $K8S_NODE_VERSION
- role: worker
  image: $K8S_NODE_VERSION
- role: worker
  image: $K8S_NODE_VERSION
- role: worker
  image: $K8S_NODE_VERSION
- role: worker
  image: $K8S_NODE_VERSION
EOF
}

teardown() {
  kind delete cluster --name $KIND_CLUSTER_NAME
}


if [ -z "$1" ]; then
  echo "Usage: launch-multinode-kind-cluster.sh {state}.  State choices are: [ up, down ]."
  exit 1
fi

STATE="${1}"

case $STATE in
  up | UP)
    startup
    ;;
  down | DOWN)
    teardown
    ;;
esac
