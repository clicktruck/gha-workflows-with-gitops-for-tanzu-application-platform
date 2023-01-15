#!/usr/bin/env bash

# Delete previously created IAM roles required for installing Tanzu Application Platform on AWS EKS integrating with ECR

# This script is based off policy documents described in https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.4/tap/aws-resources.html#create-iam-roles-5.
# Use it to remove roles created by create-tap-iam-roles.sh.

if [ -z "$1" ] && [ -z "$2" ]; then
	echo "Usage: delete-tap-iam-roles.sh {eks-cluster-name} {region}"
	exit 1
fi

export EKS_CLUSTER_NAME="$1"
export AWS_REGION="$2"

# Make sure cluster exists
cluster_name=$(aws eks list-clusters --region ${AWS_REGION} --query 'clusters[?contains(@, `${EKS_CLUSTER_NAME}`)]' | sed -n '2p' | tr -d '"' | awk '{gsub(/^ +| +$/,"")} {print $0}')

# Check to see if tap-build-service role for cluster already exists
aws iam get-role --role-name tap-build-service-for-$cluster_name
if [ $? -eq 0 ]; then
  # Delete the Tanzu Build Service Role
  aws iam delete-role --role-name tap-build-service-for-$cluster_name
else
  echo "IAM role named [ tap-build-service-for-$cluster_name ] does not exist!"
fi

# Check to see if tap-workload role for cluster already exists
aws iam get-role --role-name tap-workload-for-$cluster_name
if [ $? -eq 0 ]; then
  # Delete the Workload Role
  aws iam delete-role --role-name tap-workload-for-$cluster_name
else
  echo "IAM role named [ tap-workload-for-$cluster_name ] does not exist!"
fi
