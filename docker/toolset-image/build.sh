#!/usr/bin/env bash

# Build Toolset Image

cp -R ../../scripts .
rm -f scripts/init.sh scripts/install-prereqs*.*
cp init.sh scripts

BUILDER=${1:-docker}
IMAGE_NAME="vmware-tanzu/k8s-toolset"

if [ "docker" == "${BUILDER}" ]
then
  docker build -t ${IMAGE_NAME} .
else
  nerdctl build -t ${IMAGE_NAME} .
fi

rm -Rf scripts
