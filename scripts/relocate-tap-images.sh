#!/usr/bin/env bash

# Relocate Tanzu Application Platform images from Tanzu Network to private container image registry repository
# @see https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.5/tap/install.html#relocate-images-to-a-registry-0

if [ -z "$1" ] && [ -z "$2" ] && [ -z "$3" ] && [ -z "$4" ] && [ -z "$5" ] && [ -z "$6" ]; then
	echo "Usage: relocate-tap-imsages.sh {tanzu-network-username} {tanzu-network-password} {container-registry-url} {container-registry-username} {container-registry-password} {target-repository}"
	exit 1
fi

TANZUNET_USERNAME="${1}"
TANZUNET_PASSWORD="${2}"
REGISTRY_URL="${3}"
REGISTRY_USERNAME="${4}"
REGISTRY_PASSWORD="${5}"
TARGET_REPOSITORY="${6}"

# Set up environment variables for installation use by running:

export TAP_VERSION=1.6.1-rc.4
export TBS_FULL_DEPS_VERSION=1.10.10
export IMGPKG_REGISTRY_HOSTNAME_0=registry.tanzu.vmware.com
export IMGPKG_REGISTRY_USERNAME_0="${TANZUNET_USERNAME}"
export IMGPKG_REGISTRY_PASSWORD_0="${TANZUNET_PASSWORD}"
export IMGPKG_REGISTRY_HOSTNAME_1="${REGISTRY_URL}"
export IMGPKG_REGISTRY_USERNAME_1="${REGISTRY_USERNAME}"
export IMGPKG_REGISTRY_PASSWORD_1="${REGISTRY_PASSWORD}"
export INSTALL_REGISTRY_USERNAME="${REGISTRY_USERNAME}"
export INSTALL_REGISTRY_PASSWORD="${REGISTRY_PASSWORD}"
export INSTALL_REGISTRY_HOSTNAME="${REGISTRY_URL}"
export INSTALL_REPO="${TARGET_REPOSITORY}"

# Relocate the images with the imgpkg CLI by running:

imgpkg copy -b registry.tanzu.vmware.com/tanzu-application-platform/tap-packages:${TAP_VERSION} \
  --to-repo ${INSTALL_REGISTRY_HOSTNAME}/${INSTALL_REPO}/tap-packages

# @see https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.5/tap/install.html#install-the-full-dependencies-package-6
imgpkg copy -b registry.tanzu.vmware.com/tanzu-application-platform/full-tbs-deps-package-repo:${TBS_FULL_DEPS_VERSION} \
  --to-repo ${INSTALL_REGISTRY_HOSTNAME}/${INSTALL_REPO}/tbs-full-deps
