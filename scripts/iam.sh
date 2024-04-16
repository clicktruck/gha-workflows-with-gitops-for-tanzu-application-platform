#!/usr/bin/env bash

# This script helps set up IAM service account credentials on various public clouds

# @author Chris Phillipson
# @version 2.0

# Prerequisities:
## - *nix OS
## - Public Internet access
## - Cloud provider CLI installed (e.g., aws, az, gcloud)
## - Cloud provider account admin credentials in addition to storage account credentials
## - Pre-authenticated with cloud provider account admin credentials

IAM_CONFIG=$(cat <<EOF
#!/usr/bin/env bash

## IAAS must be set to one of [ aws, azure, gcp ]
IAAS="REPLACE_ME"

SERVICE_ACCOUNT_NAME="tap-admin"


## AKS specific

AZ_REGION="West US 2"
AZ_SUBSCRIPTION_ID="REPLACE_ME"
AZ_TENANT_ID="REPLACE_ME"
AZ_APP_NAME="$SERVICE_ACCOUNT_NAME"
# Secret you select here must adhere to Azure's password policy
AZ_CLIENT_SECRET="REPLACE_ME"
# An existing resource group
AZ_RESOURCE_GROUP="REPLACE_ME"
AZ_STORAGE_ACCOUNT_NAME="REPLACE_ME"


## EKS specific

AWS_SERVICE_ACCOUNT="$SERVICE_ACCOUNT_NAME"
# @see https://aws.amazon.com/blogs/security/aws-iam-introduces-updated-policy-defaults-for-iam-user-passwords/
AWS_SERVICE_ACCOUNT_PASSWORD="REPLACE_ME"
AWS_REGION="us-west-2"

# Supply existing administrator credentials here (must have iam:CreateUser)
# We'll create a new service account that will itself have administrator privileges
# Values here will be replaced with those of the service account
AWS_ACCESS_KEY="REPLACE_ME"
AWS_SECRET_KEY="REPLACE_ME"


## GKE specific

GCP_PROJECT="prow-openbtr-dev"
GCP_SERVICE_ACCOUNT="$SERVICE_ACCOUNT_NAME"
GCP_REGION="us-west1"
EOF
)

if [ -d "$HOME/.iam" ]; then
  if [ -f "$HOME/.iam/config" ]; then
    source $HOME/.iam/config
  else
    echo "Writing sample config to $HOME/.iam/config.  Edit the file and re-run this script again."
    echo "$IAM_CONFIG" > $HOME/.iam/config
    exit 1
  fi
else
  mkdir $HOME/.iam
  echo "Writing sample config to $HOME/.iam/config.  Edit the file and re-run this script again."
  echo "$IAM_CONFIG" > $HOME/.iam/config
  exit 1
fi


# Authenticate, create service account, enable bucket versioning
case "$IAAS" in
  aws)
      export AWS_PAGER=""
      # Thanks to https://docs.aws.amazon.com/IAM/latest/UserGuide/getting-started_create-admin-group.html and https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html
      aws configure
      aws iam create-group --group-name Admins
      aws iam attach-group-policy --group-name Admins --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
      aws iam create-user –-user-name $AWS_SERVICE_ACCOUNT
      aws create-login-profile --username $AWS_SERVICE_ACCOUNT --password $AWS_SERVICE_ACCOUNT_PASSWORD --no-password-reset-required true
      aws iam add-user-to-group --user-name $AWS_SERVICE_ACCOUNT --group-name Admins
      aws iam create-access-key --user-name $AWS_SERVICE_ACCOUNT > key.txt
      AWS_ACCESS_KEY=$(cat key.txt | jq -r ".AccessKey.AccessKeyId")
      AWS_SECRET_KEY=$(cat key.txt | jq -r ".AccessKey.SecretAccessKey")
      rm -rf key.txt

      echo "AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY"
      echo "AWS_SECRET_ACCESS_KEY=$AWS_SECRET_KEY"
      ;;

  azure)
      # Thanks to https://markheath.net/post/create-service-principal-azure-cli
      az login
      az account set -s $AZ_SUBSCRIPTION_ID
      az ad app create --display-name $AZ_APP_NAME --homepage "http://localhost/$AZ_APP_NAME"
      AZ_APP_ID=$(az ad app list --display-name $AZ_APP_NAME | jq '.[0].appId' | tr -d '"')
      az ad sp create-for-rbac --name $AZ_APP_ID --role="Contributor" --scopes="/subscriptions/$AZ_SUBSCRIPTION_ID/resourceGroups/$AZ_RESOURCE_GROUP"
      az ad sp credential reset --name "$AZ_APP_ID" --password "${AZ_CLIENT_SECRET}"
      AZ_CLIENT_ID=$(az ad sp list --display-name $AZ_APP_ID | jq '.[0].appId' | tr -d '"')
      # @see https://docs.microsoft.com/en-us/azure/role-based-access-control/role-assignments-cli
      az role assignment create --assignee "$AZ_CLIENT_ID" --role "Owner" --subscription "$AZ_SUBSCRIPTION_ID"

      az storage account create -n $AZ_STORAGE_ACCOUNT_NAME -g $AZ_RESOURCE_GROUP -l "$AZ_REGION" --sku Standard_LRS
      az storage account blob-service-properties update --enable-versioning -n $AZ_STORAGE_ACCOUNT_NAME -g $AZ_RESOURCE_GROUP

      echo "AZ_CLIENT_ID is $AZ_CLIENT_ID"
      ;;

  gcp)
      mkdir -p $HOME/.google
      gcloud auth login
      gcloud config set project $GCP_PROJECT
      gcloud iam service-accounts create $GCP_SERVICE_ACCOUNT
      gcloud projects add-iam-policy-binding $GCP_PROJECT --member="serviceAccount:$GCP_SERVICE_ACCOUNT@$GCP_PROJECT.iam.gserviceaccount.com" --role="roles/owner"
      gcloud iam service-accounts keys create $HOME/.google/$GCP_SERVICE_ACCOUNT.$GCP_PROJECT.json --iam-account=$GCP_SERVICE_ACCOUNT@$GCP_PROJECT.iam.gserviceaccount.com

      echo "Service account key file location:  $HOME/.google/$GCP_SERVICE_ACCOUNT.$GCP_PROJECT.json"
      ;;

  *)
      echo -e "IAAS must be set to one of [ aws, azure, gcp ]"
      exit 1
esac
