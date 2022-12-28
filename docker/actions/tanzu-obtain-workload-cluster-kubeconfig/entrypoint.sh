#!/usr/bin/env bash

# Entrypoint for tanzu-runsh-setup-action

# This script expects that the following environment variables have been set:
#
# * CSP_API_TOKEN
# * TANZU_CLI_VERSION
# * TANZU_CLI_CORE_VERSION
#
# If you intend to run this script as the ENTRYPOINT in a Docker file then pass
# each of the environment variables above with -e (e.g., -e TANZU_CLI_VERSION=1.6.0).
#
# If you intend to run this script standalone then you will need to export each of
# the environment variables above (e.g., export TANZU_CLI_VERSION=1.6.0) beforehand.

if [ x"${CSP_API_TOKEN}" == "x" ] || [ x"${TANZU_CLI_VERSION}" == "x" ] || [ x"${TANZU_CLI_CORE_VERSION}" == "x" ]; then
  echo "Expected CSP_API_TOKEN, TANZU_CLI_VERSION, and TANZU_CLI_CORE_VERSION enviroment variables to have been set!"
  exit 1;
fi

echo "- Decoding the management cluster's KUBECONFIG contents and saving output to /tmp/.kube-tkg/config"
mkdir -p /tmp/.kube-tkg

if [ "$2" == "" ] && [ "$3" == "" ]; then
  echo "You must supply either new or existing base64 encoded TKG management cluster contents"
  exit 1
fi

if [ "$2" != "" ]; then
  echo "$2" | base64 -d > /tmp/.kube-tkg/config
fi

if [ "$3" != "" ]; then
  echo "$3" | base64 -d > /tmp/.kube-tkg/config
fi

chmod 600 /tmp/.kube-tkg/config

management_cluster_name=$(cat /tmp/.kube-tkg/config | yq '.clusters[].name')
echo "- Management cluster name is [ $management_cluster_name ]"

OS=linux
FILE=tanzu-cli-bundle-${OS}-amd64.tar.gz
CURRENT_VERSION="latest"
DIST_EXECUTABLE="dist/tanzu"
TANZU_CLI="tanzu"

if [ -e "$DIST_EXECUTABLE" ]; then
  cd dist
  TANZU_CLI_VERSION_OUTPUT=$(${TANZU_CLI} version)
  MULTI_LINE_STRING=${TANZU_CLI_VERSION_OUTPUT#"version: v"}
  OUTPUT_ARRAY=(${MULTI_LINE_STRING[@]})
  CURRENT_VERSION=${OUTPUT_ARRAY[0]}
  cd ..
fi

echo "Confirming whether tanzu CLI needs to be downloaded..."
if [ "$TANZU_CLI_VERSION" == "$CURRENT_VERSION" ]; then
  echo "$FILE already downloaded."
else
  echo "$FILE does not exist. Will begin fetching from https://console.cloud.vmware.com."
  mkpcli download --product tanzu-kubernetes-grid-1-1-1211 --product-version $TANZU_CLI_VERSION --filter $FILE --csp-api-token $CSP_API_TOKEN --accept-eula


  mkdir -p dist
  tar xvf $FILE -C dist

  echo "Moving tanzu CLI into place."
  chmod +x dist/cli/core/v${TANZU_CLI_CORE_VERSION}/tanzu-core-${OS}_amd64
  cp dist/cli/core/v${TANZU_CLI_CORE_VERSION}/tanzu-core-${OS}_amd64 ${DIST_EXECUTABLE}
  mv ${DIST_EXECUTABLE} /usr/bin

  echo "Initialize and validate tanzu CLI."
  tanzu init
  tanzu version

  echo "Installing plugins for use with tanzu CLI."
  tanzu plugin clean
  cd dist/cli
  tanzu plugin sync
  cd ../..

  echo "Verifying plugins are installed."
  tanzu plugin list

  echo "Cleaning up."
  rm -Rf dist tanzu-cli-bundle-linux-amd64.tar.gz;
fi

WORKLOAD_CLUSTER_NAME="$1"

echo "- Obtaining the workload cluster's KUBECONFIG contents and saving output to /tmp/.kube/config"
mkdir -p /tmp/.kube
tanzu cluster kubeconfig get ${WORKLOAD_CLUSTER_NAME} --admin --export-file /tmp/.kube/config

echo "- Base64 encoding the workload cluster's KUBECONFIG file contents"
kubeconfig_contents=$(cat /tmp/.kube/config | base64 -w 0)
echo "kubeconfig_contents=$kubeconfig_contents" >> $GITHUB_OUTPUT
