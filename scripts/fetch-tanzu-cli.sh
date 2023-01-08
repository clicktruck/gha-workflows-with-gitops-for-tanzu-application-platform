#!/usr/bin/env bash

if [ -z "$1" ] && [ -z "$2" ] && [ -z "$3" ] && [ -z "$4" ]; then
	echo "Usage: fetch-tanzu-cli.sh {csp-api-token} {os} {tanzu-cli-version} {tanzu-cli-core-version}"
	exit 1
fi

CSP_API_TOKEN="$1"
OS="$2"
TANZU_CLI_VERSION="$3"
TANZU_CLI_CORE_VERSION="$4"
MKPCLI_VERSION=0.15.1

if ! command -v mkpcli &> /dev/null
then
  echo "Downloading VMware Marketplace CLI..."
	curl -LO https://github.com/vmware-labs/marketplace-cli/releases/download/v${MKPCLI_VERSION}/mkpcli-linux-amd64.tgz
  tar -xvf mkpcli-linux-amd64.tgz
	chmod +x mkpcli
	sudo mv mkpcli /usr/local/bin
fi

FILE=tanzu-cli-bundle-${OS}-amd64.tar.gz
CURRENT_VERSION="latest"
DIST_EXECUTABLE="dist/tanzu"
TANZU_CLI="tanzu"
if [ "$OS" == "windows" ]; then
  TANZU_CLI = "tanzu.exe"
  DIST_EXECUTABLE = "dist/tanzu.exe"
fi
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
    mkdir -p dist
    mkpcli download --product tanzu-kubernetes-grid-1-1-1211 --product-version $TANZU_CLI_VERSION --filter $FILE --csp-api-token $CSP_API_TOKEN --accept-eula

    echo "Unpacking $FILE."
    tar xvf $FILE -C dist

    echo "Moving tanzu CLI into place."
    if [ "$OS" == "windows" ]; then
      cp dist/cli/core/v${TANZU_CLI_CORE_VERSION}/tanzu-core-${OS}_amd64.exe ${DIST_EXECUTABLE}
    else
      chmod +x dist/cli/core/v${TANZU_CLI_CORE_VERSION}/tanzu-core-${OS}_amd64
      cp dist/cli/core/v${TANZU_CLI_CORE_VERSION}/tanzu-core-${OS}_amd64 ${DIST_EXECUTABLE}
    fi
    sudo mv ${DIST_EXECUTABLE} /usr/local/bin

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
    rm -Rf dist tanzu-cli-bundle-linux-amd64.tar.gz
fi
