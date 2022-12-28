#!/usr/bin/env bash

# USAGE:
# export AWS_SERVICE_ACCOUNT_NAME=<an account name>
# export AWS_SERVICE_ACCOUNT_PASSWORD=<an account password>
#
# scripts/aws/create-aws-service-account.sh

set -eo pipefail

if [ -z "$AWS_SERVICE_ACCOUNT_NAME" ] || [ -z "$AWS_SERVICE_ACCOUNT_PASSWORD" ]; then
    echo -e "One or more variables are not defined. Required environment variables are:\nAWS_SERVICE_ACCOUNT_NAME\nAWS_SERVICE_ACCOUNT_PASSWORD"
    exit 1
fi

# Disable paging of JSON results
export AWS_PAGER=""

# Create a service account with specified role

# Thanks to https://docs.aws.amazon.com/IAM/latest/UserGuide/getting-started_create-admin-group.html and https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html
aws configure  # Enter the AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, and AWS_REGION for the root account
aws iam create-group --group-name Admins
aws iam attach-group-policy --group-name Admins --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
aws iam create-user --user-name $AWS_SERVICE_ACCOUNT_NAME
aws create-login-profile --username $AWS_SERVICE_ACCOUNT_NAME --password $AWS_SERVICE_ACCOUNT_PASSWORD --no-password-reset-required true
aws iam add-user-to-group --user-name $AWS_SERVICE_ACCOUNT_NAME --group-name Admins
aws iam create-access-key --user-name $AWS_SERVICE_ACCOUNT_NAME > key.txt
AWS_ACCESS_KEY=$(cat key.txt | jq -r ".AccessKey.AccessKeyId")
AWS_SECRET_KEY=$(cat key.txt | jq -r ".AccessKey.SecretAccessKey")
rm -rf key.txt

echo "AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY"
echo "AWS_SECRET_ACCESS_KEY=$AWS_SECRET_KEY"
