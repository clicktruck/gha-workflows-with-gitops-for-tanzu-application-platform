#!/usr/bin/env bash

# Delete previously created IAM roles required for installing Tanzu Application Platform on AWS EKS integrating with ECR

# This script is based off policy documents described in https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.5/tap/aws-resources.html#create-iam-roles-5.
# Use it to remove roles created by create-tap-iam-roles.sh.

if [ -z "$1" ] && [ -z "$2" ]; then
	echo "Usage: delete-tap-iam-roles.sh {eks-cluster-name} {aws-region}"
	exit 1
fi

set -x
export CLUSTER_NAME_STARTS_WITH="$1*"

export AWS_PAGER=""
export AWS_REGION="$2"
export EKS_CLUSTER_NAME=$(aws eks list-clusters --region ${AWS_REGION} | yq -p=json '.clusters[] | select(. == env(CLUSTER_NAME_STARTS_WITH))')
set +x

if [ -z "$EKS_CLUSTER_NAME" ]; then
  echo "No cluster found matching wildcarded id $CLUSTER_NAME_STARTS_WITH"
  exit 1
fi


# Check to see if tap-build-service role for cluster already exists
aws iam get-role --role-name tap-build-service-for-$EKS_CLUSTER_NAME 2> /dev/null
if [ $? -eq 0 ]; then
  # Delete the Tanzu Build Service Role
  aws iam delete-role-policy --role-name tap-build-service-for-$EKS_CLUSTER_NAME --policy-name tapBuildServicePolicy
  aws iam delete-role --role-name tap-build-service-for-$EKS_CLUSTER_NAME
else
  echo "IAM role named [ tap-build-service-for-$EKS_CLUSTER_NAME ] does not exist!"
fi

# Check to see if tap-workload role for cluster already exists
aws iam get-role --role-name tap-workload-for-$EKS_CLUSTER_NAME 2> /dev/null
if [ $? -eq 0 ]; then
  # Delete the Workload Role
  aws iam delete-role-policy --role-name tap-workload-for-$EKS_CLUSTER_NAME --policy-name tapWorkload
  aws iam delete-role --role-name tap-workload-for-$EKS_CLUSTER_NAME
else
  echo "IAM role named [ tap-workload-for-$EKS_CLUSTER_NAME ] does not exist!"
fi
