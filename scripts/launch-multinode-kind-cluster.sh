#!/usr/bin/env bash

# @see https://kind.sigs.k8s.io/docs/user/ingress/#create-cluster

export KIND_CLUSTER_NAME=kind-demo
export K8S_NODE_VERSION=kindest/node:v1.26.6@sha256:5e5d789e90c1512c8c480844e0985bc3b4da4ba66179cc5b540fe5b785ca97b5

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
