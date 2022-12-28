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

if [ "${TANZU_CLI_ENABLED}" == "true" ]; then
  if [ x"${CSP_API_TOKEN}" == "x" ] || [ x"${TANZU_CLI_VERSION}" == "x" ] || [ x"${TANZU_CLI_CORE_VERSION}" == "x" ]; then
    echo "Expected CSP_API_TOKEN, TANZU_CLI_VERSION, and TANZU_CLI_CORE_VERSION enviroment variables to have been set!"
    exit 1;
  fi

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
else
  echo "Not installing tanzu CLI nor configuring plugins"
fi

if [ -z "$3" ]; then
  echo "Base64 encoded KUBECONFIG contents not supplied"
else
  echo "Exporting KUBECONFIG environment variable."
  mkdir -p $HOME/.kube
  echo "$3" | base64 -d > $HOME/.kube/config
  chmod 600 $HOME/.kube/config
  export KUBECONFIG=$HOME/.kube/config
fi

echo "Executing script."
echo "$1" | base64 -d > run.sh
chmod +x run.sh
read -r -a args <<< "$2"
. ./run.sh ${args[@]}
