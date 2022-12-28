#!/usr/bin/env bash

set -eo pipefail

# Automates wildcard ClusterIssuer, Certificate and Secret generation on a K8s cluster where cert-manager is already installed.

if [ -z "$1" ]; then
	echo "Usage: install-smallstep.sh {domain}"
	exit 1
fi

DOMAIN="$1"

## Create namespace where cert and tls secret will reside
kubectl create namespace contour-tls --dry-run=client -o yaml | kubectl apply -f -

## Install step-certificates and step-issuer Helm charts

helm repo add smallstep  https://smallstep.github.io/helm-charts
helm repo update
helm install step-certificates smallstep/step-certificates --namespace small-step --create-namespace --wait
helm install step-issuer smallstep/step-issuer --namespace small-step --create-namespace --wait

## Get step-certificates root certificate

ROOT_CERT=$(kubectl get -o jsonpath="{.data['root_ca\.crt']}" configmaps/step-certificates-certs -n small-step | base64 -w 0)

## Get the step-certificate provisioner information
KID=$(kubectl get -o jsonpath="{.data['ca\.json']}" configmaps/step-certificates-config -n small-step | jq .authority.provisioners | jq  '.[0].key.kid' | tr -d '"')

## Create StepClusterIssuer

cat > step-cluster-issuer.yaml <<EOF
---
apiVersion: certmanager.step.sm/v1beta1
kind: StepClusterIssuer
metadata:
  name: step-cluster-issuer
spec:
  url: https://step-certificates.small-step.svc.cluster.local
  caBundle: ${ROOT_CERT}
  provisioner:
    name: admin
    kid: ${KID}
    passwordRef:
      namespace: small-step
      name: step-certificates-provisioner-password
      key: password
EOF

kubectl apply -f step-cluster-issuer.yaml
