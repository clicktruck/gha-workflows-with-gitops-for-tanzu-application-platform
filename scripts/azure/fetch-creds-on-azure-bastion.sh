#!/usr/bin/env bash

# USAGE:
# ./fetch-creds-on-azure-bastion.sh

set -eo pipefail

az login --identity

# Pull down kubeconfig into home dir
kv=$(az keyvault list | jq -r '.[0].name')
az keyvault secret show --name tap-base64-kubeconfig --vault-name $kv | jq -r .value | base64 -d > /home/ubuntu/aks-kubeconfig.yml
chown ubuntu:ubuntu /home/ubuntu/aks-kubeconfig.yml
chown 600 /home/ubuntu/aks-kubeconfig.yml
mkdir -p /home/ubuntu/.kube
chown -R ubuntu:ubuntu /home/ubuntu/.kube/
cp /home/ubuntu/aks-kubeconfig.yml /home/ubuntu/.kube/config
chown 600 /home/ubuntu/.kube/config

# Pull down ACR creds
az keyvault secret show --name acr-user --vault-name $kv | jq -r .value  > /home/ubuntu/acr-user
az keyvault secret show --name acr-password --vault-name $kv | jq -r .value  > /home/ubuntu/acr-password
chown ubuntu:ubuntu /home/ubuntu/acr-user
chown ubuntu:ubuntu /home/ubuntu/acr-password