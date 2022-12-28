#!/usr/bin/env bash
set -eo pipefail

# Nuke an existing cluster (management or workload) using leftovers CLI
# @see https://github.com/genevieve/leftovers

## Do not change anything below unless you know what you're doing!

if [ -z "$1" ]; then
	echo "Usage: nuke-tkg-cluster-on-aws.sh {base64-encoded-cluster-kubeconfig-contents}"
	exit 1
fi

if [ x"${AWS_ACCESS_KEY_ID}" == "x" ] || [ x"${AWS_SECRET_ACCESS_KEY}" == "x" ] && [ x"${AWS_REGION}" == "x" ]; then
  exit 1;
fi

mkdir -p /tmp/.kube-tkg
echo "$1" | base64 -d > /tmp/.kube-tkg/config
chmod 600 /tmp/.kube-tkg/config

cluster_name=$(cat /tmp/.kube-tkg/config | yq '.clusters[].name')
statement="Nuking ${cluster_name} which will include VPC and EC2 resources."

if [ x"${AWS_SESSION_TOKEN}" == "x" ]; then
  echo "Session token not supplied."
  echo "${statement}"
  leftovers --aws-region=$AWS_REGION --aws-access-key-id=$AWS_ACCESS_KEY_ID --aws-secret-access-key=$AWS_SECRET_ACCESS_KEY --filter ${cluster_name} --iaas=aws --no-confirm
else
  echo "Session token supplied."
  echo "${statement}"
  leftovers --aws-region=$AWS_REGION --aws-access-key-id=$AWS_ACCESS_KEY_ID --aws-secret-access-key=$AWS_SECRET_ACCESS_KEY --aws-session-token=$AWS_SESSION_TOKEN --filter ${cluster_name} --iaas=aws --no-confirm
fi
