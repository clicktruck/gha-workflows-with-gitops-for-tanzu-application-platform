#!/usr/bin/env bash
set -eo pipefail

## This script downloads and installs OSS kapp-controller and secretgen-controller into a target Kubernetes cluster

## Do not change anything below unless you know what you're doing!

if [ -z "$1" ] && [ "x$KUBECONFIG" != "x" ]; then
  echo "KUBECONFIG is already set"
else
  mkdir -p /tmp/.kube
  KUBECONFIG_CONTENTS="$1"
  echo "$KUBECONFIG_CONTENTS" | base64 -d > /tmp/.kube/config
  chmod 600 /tmp/.kube/config
  export KUBECONFIG=/tmp/.kube/config
fi

kubectl apply -f https://github.com/vmware-tanzu/carvel-kapp-controller/releases/latest/download/release.yml
kubectl apply -f https://github.com/vmware-tanzu/carvel-secretgen-controller/releases/latest/download/release.yml
