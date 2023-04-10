#!/usr/bin/env bash

# Prepare metadata-store secrets for TAP multi-cluster footprint
# Collect token and ca-cert from cluster hosting TAP view profile
# Create secrets in namespace on cluster hosting TAP build profile

# Based upon procedure described here: https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.5/tap/scst-store-multicluster-setup.html

# Inputs:
# * base64-encoded kubeconfig contents for cluster hosting TAP view profile
# * base64-encoded kubeconfig contents for cluster hosting TAP build profile


if [ -z "$1" ] && [ -z "$2" ]; then
	echo "Usage: prepare-metadata-store.sh {base64-encoded-kubeconfig-contents-of-tap-view-cluster} {base64-encoded-kubeconfig-contents-of-tap-build-cluster}"
	exit 1
fi

SECRETS_NAMESPACE=metadata-store-secrets
TAP_VIEW_KUBECONFIG_CONTENTS=${1}
TAP_BUILD_KUBECONFIG_CONTENTS=${2}

mkdir -p /tmp/.kube
echo "$TAP_VIEW_KUBECONFIG_CONTENTS" | base64 --decode > /tmp/.kube/tap-view-config
echo "$TAP_BUILD_KUBECONFIG_CONTENTS" | base64 --decode > /tmp/.kube/tap-build-config
chmod 600 /tmp/.kube/tap-*-config


# Commands executed targeting cluster hosting TAP view profile

export KUBECONFIG=/tmp/.kube/tap-view-config

CA_CERT=$(kubectl get secret -n metadata-store ingress-cert -o json | jq -r ".data.\"ca.crt\"")
cat <<EOF > store_ca.yaml
---
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: store-ca-cert
  namespace: $SECRETS_NAMESPACE
data:
  ca.crt: $CA_CERT
EOF

AUTH_TOKEN=$(kubectl get secrets metadata-store-read-write-client -n metadata-store -o jsonpath="{.data.token}" | base64 -d)


# Commands executed targeting cluster hosting TAP build profile

export KUBECONFIG=/tmp/.kube/tap-build-config

kubectl create ns ${SECRETS_NAMESPACE} \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl apply -f store_ca.yaml

kubectl delete secret store-auth-token \
  --ignore-not-found

kubectl create secret generic store-auth-token \
  --from-literal=auth_token=$AUTH_TOKEN -n ${SECRETS_NAMESPACE} \
  --dry-run=client -o yaml | kubectl apply -f -
