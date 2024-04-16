#!/bin/bash
set -eo pipefail

if [ -z "$1" ]; then
	echo "Usage: install-tap-plugins.sh {os}"
	exit 1
fi

OS=${1}
TAP_VERSION=1.6.4

# Installs TAP plugins for tanzu CLI

function install_tanzu_cli() {
case $1 in
  linux)
    sudo mkdir -p /etc/apt/keyrings/
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl gpg
    curl -fsSL https://packages.vmware.com/tools/keys/VMWARE-PACKAGING-GPG-RSA-KEY.pub | sudo gpg --dearmor -o /etc/apt/keyrings/tanzu-archive-keyring.gpg
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/tanzu-archive-keyring.gpg] https://storage.googleapis.com/tanzu-cli-os-packages/apt tanzu-cli-jessie main" | sudo tee /etc/apt/sources.list.d/tanzu.list
    sudo apt-get update
    sudo apt-get install -y tanzu-cli
    ;;

  mac)
    if ! command -v brew &> /dev/null
    then
      brew update && brew install vmware-tanzu/tanzu/tanzu-cli
    fi
    ;;
esac
}

function install_tap_plugins() {
  tanzu plugin install --group vmware-tap/default:v$1
  tanzu plugin list
}

if command -v tanzu > /dev/null; then
  echo "tanzu CLI installed." && install_tap_plugins $TAP_VERSION
else
  echo "tanzu CLI is not installed."
  install_tanzu_cli $OS
  install_tap_plugins $TAP_VERSION
fi