#!/bin/bash
set -eo pipefail

ENABLE_NS_DELETE=${1:-1}

# Remove Smallstep managed Certificate plus Secret and ClusterIssuer

## Delete StepClusterIssuer
kubectl delete stepclusterissuer step-cluster-issuer --ignore-not-found=true

## Delete Certificate
kubectl delete cert tls -n contour-tls --ignore-not-found=true

## Delete Secrets
kubectl delete secret tls -n contour-tls --ignore-not-found=true

## Delete namespace
if [ $ENABLE_NS_DELETE -gt 0 ]; then
  kubectl delete namespace contour-tls --ignore-not-found=true
fi

## Uninstall Helm charts
helm uninstall step-issuer -n small-step
helm uninstall step-certificates -n small-step
kubectl delete namespace small-step --ignore-not-found=true
