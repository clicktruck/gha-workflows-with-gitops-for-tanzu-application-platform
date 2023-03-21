#!/usr/bin/env bash

# USAGE:
# export AZURE_SUBSCRIPTION_ID=<your subscription>
# Service principal name must be unique within your subscription
# export AZURE_SP_NAME=tanzu-application-platform-sp
# export AZURE_SP_ROLE=Owner

# scripts/azure/create-azure-service-principal.sh

set -eo pipefail

if [ -z "$AZURE_SUBSCRIPTION_ID" ] || [ -z "$AZURE_SP_NAME" ] || [ -z "$AZURE_SP_ROLE" ]; then
    echo -e "One or more variables are not defined! Required environment variables are:\n- AZURE_SUBSCRIPTION_ID\n- AZURE_SP_NAME\n- AZURE_SP_ROLE"
    exit 1
fi

# Authenticate
az login
# Create a SP with specified role
az account set -s $AZURE_SUBSCRIPTION_ID
# The az CLI says --sdk-auth is deprecated but doesn't give a new option. This is required for the Github Action though.
az ad sp create-for-rbac --name $AZURE_SP_NAME --role $AZURE_SP_ROLE \
    --scopes /subscriptions/${AZURE_SUBSCRIPTION_ID} \
    --sdk-auth
