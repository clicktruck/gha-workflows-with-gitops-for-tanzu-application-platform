#!/bin/bash
set -eo pipefail

# Downloads the Tanzu Gitops Reference Implementation install script and assets from Tanzu Network

if [ -z "$1" ]; then
	echo "Usage: fetch-tap-vscode-extension.sh {tanzu-network-api-token}"
	exit 1
fi

if ! command -v pivnet &> /dev/null
then
    echo "Downloading pivnet CLI..."
	curl -LO https://github.com/pivotal-cf/pivnet-cli/releases/download/v3.0.1/pivnet-linux-amd64-3.0.1
	chmod +x pivnet-linux-amd64-3.0.1
	sudo mv pivnet-linux-amd64-3.0.1 /usr/local/bin/pivnet
fi


TANZU_NETWORK_API_TOKEN="$1"
pivnet login --api-token=$TANZU_NETWORK_API_TOKEN

cd /tmp
TAP_VERSION="1.5.2"
TAP_GITOPS_RI_VERSION="0.1.0"

# Download Tanzu GitOps Reference Implementation
TAP_PRODUCT_FILE_ID=1467377
pivnet download-product-files --product-slug='tanzu-application-platform' --release-version="${TAP_VERSION}" --product-file-id="${TAP_PRODUCT_FILE_ID}"
ls -la tanzu-gitops-ri-${TAP_GITOPS_RI_VERSION}.tgz
