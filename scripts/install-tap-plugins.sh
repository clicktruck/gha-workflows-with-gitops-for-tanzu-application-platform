#!/bin/bash
set -eo pipefail

if [ -z "$1" ]; then
	echo "Usage: install-tap-plugins.sh {tanzu-network-api-token}"
	exit 1
fi

OS="$(uname | tr '[:upper:]' '[:lower:]')"
case $OS in
  darwin)
    echo "Installing MacOS version of Tanzu Application Platform plugins for tanzu CLI"
	TAP_PRODUCT_FILE_ID=1478716
    ;;

  linux)
    echo "Installing Linux version of Tanzu Application Platform plugins for tanzu CLI"
	TAP_PRODUCT_FILE_ID=1478717
    ;;

  *)
    echo "[ Unsupported OS ] cannot install Tanzu Application Platform plugins for tanzu CLI"
	exit 1
    ;;
esac

if ! command -v pivnet &> /dev/null
then
    echo "Downloading pivnet CLI..."
	curl -LO https://github.com/pivotal-cf/pivnet-cli/releases/download/v3.0.1/pivnet-${OS}-amd64-3.0.1
	chmod +x pivnet-${OS}-amd64-3.0.1
	sudo mv pivnet-${OS}-amd64-3.0.1 /usr/local/bin/pivnet
fi


TANZU_NETWORK_API_TOKEN="$1"
pivnet login --api-token=$TANZU_NETWORK_API_TOKEN

mkdir -p $HOME/tanzu
cd /tmp
TAP_VERSION="1.5.2-rc.2"

export TANZU_CLI_NO_INIT=true
cd $HOME/tanzu
export CORE_VERSION=v0.28.1

pivnet download-product-files --product-slug='tanzu-application-platform' --release-version="${TAP_VERSION}" --product-file-id="${TAP_PRODUCT_FILE_ID}"
tar -xvf tanzu-framework-${OS}-amd64-${CORE_VERSION}*.tar -C $HOME/tanzu

if [ -f "/usr/local/bin/tanzu" ]; then
  cd $HOME/tanzu
  tanzu plugin delete package || true
  tanzu plugin install apps --local ./cli
  tanzu plugin install insight --local ./cli
  tanzu plugin install secret --local ./cli
  tanzu plugin install services --local ./cli
  tanzu plugin install accelerator --local ./cli
  tanzu plugin install package --local ./cli
  tanzu version
else
  sudo install cli/core/${CORE_VERSION}/tanzu-core-${OS}_amd64 /usr/local/bin/tanzu
  tanzu version
  tanzu plugin install --local cli all
fi

tanzu plugin list
