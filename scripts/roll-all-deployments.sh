#!/usr/bin/env bash

# Get all namespaces
namespaces=$(kubectl get namespaces -o jsonpath='{.items[*].metadata.name}')

# Loop through each namespace
for namespace in $namespaces; do
  echo "Namespace: $namespace"

  # Get all deployments in the namespace
  deployments=$(kubectl get deployments -n "$namespace" -o jsonpath='{.items[*].metadata.name}')

  # Loop through each deployment
  for deployment in $deployments; do
    echo "Restarting deployment: $deployment"
    kubectl rollout restart deployment "$deployment" -n "$namespace"
  done
done
