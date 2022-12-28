#!/usr/bin/env bash

# Entrypoint for eks-kubeconfig-action

# This script expects that the following environment variables have been set:
#
# * AWS_ACCESS_KEY_ID
# * AWS_SECRET_ACCESS_KEY
#
# If you intend to run this script as the ENTRYPOINT in a Docker file then pass
# each of the environment variables above with -e (e.g., -e AWS_ACCESS_KEY_ID=xxx).
#
# If you intend to run this script standalone then you will need to export each of
# the environment variables above (e.g., export AWS_ACCESS_KEY_ID=xxx) beforehand.

if [ x"${AWS_ACCESS_KEY_ID}" == "x" ] || [ x"${AWS_SECRET_ACCESS_KEY}" == "x" ]; then
  echo "Expected AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY enviroment variables to have been set!"
  exit 1;
fi

if [ x"${AWS_SESSION_TOKEN}" == "x" ]; then
  echo "Session token not supplied."
else
  echo "Session token supplied."
fi

echo "Validate eksctl CLI."
eksctl version

mkdir -p $HOME/.kube/eksctl/clusters
eksctl utils write-kubeconfig --cluster="$1" --region="$2" --auto-kubeconfig
kubeconfig_contents=$(cat "$HOME/.kube/eksctl/clusters/$1")
b64kubeconfig=$(echo "${kubeconfig_contents}" | base64 -w 0)
echo "b64kubeconfig=${b64kubeconfig}" >> $GITHUB_OUTPUT
