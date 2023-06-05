#!/usr/bin/env bash

# Entrypoint for tanzu-tkg-management-cluster-create

# This script expects that the following environment variables have been set:
#
# * CSP_API_TOKEN
# * TANZU_CLI_VERSION
# * TANZU_CLI_CORE_VERSION
# * AWS_ACCESS_KEY_ID
# * AWS_SECRET_ACCESS_KEY
#
# If you intend to run this script as the ENTRYPOINT in a Docker file then pass
# each of the environment variables above with -e (e.g., -e TANZU_CLI_VERSION=2.2.0).
#
# If you intend to run this script standalone then you will need to export each of
# the environment variables above (e.g., export TANZU_CLI_VERSION=2.2.0) beforehand.

if [ x"${CSP_API_TOKEN}" == "x" ] || [ x"${TANZU_CLI_VERSION}" == "x" ] || [ x"${TANZU_CLI_CORE_VERSION}" == "x" ]; then
  echo "Expected CSP_API_TOKEN, TANZU_CLI_VERSION, and TANZU_CLI_CORE_VERSION enviroment variables to have been set!"
  exit 1;
fi

if [ x"${AWS_ACCESS_KEY_ID}" == "x" ] || [ x"${AWS_SECRET_ACCESS_KEY}" == "x" ]; then
  echo "Expected AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY enviroment variables to have been set!"
  exit 1;
fi

if [ x"${AWS_SESSION_TOKEN}" == "x" ]; then
  echo "Session token not supplied."
else
  echo "Session token supplied."
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

if [ -z "$GITHUB_WORKSPACE" ]; then
  GITOPS_DIR=../"$1"
else
  GITOPS_DIR=$GITHUB_WORKSPACE/$1
fi

cd ${GITOPS_DIR}


if [ -z "$3" ]; then
  echo "Base64 encoded KUBECONFIG contents for a management cluster not supplied"

  if [ -z "$2" ]; then
    echo "Base64 encoded KUBECONFIG contents for bootstrap cluster not supplied"
    exit 1
  else
    echo "Exporting KUBECONFIG environment variable."
    mkdir -p $HOME/.kube
    echo "$2" | base64 -d > $HOME/.kube/config
    chmod 600 $HOME/.kube/config
    export KUBECONFIG=$HOME/.kube/config
  fi

  echo "-- Creating management cluster with"
  cat cluster.yml

  tanzu management-cluster create --file cluster.yml --use-existing-bootstrap-cluster --yes --verbose 6

  mkdir -p /tmp/.kube-tkg
  echo "- Exporting management cluster's KUBECONFIG contents to file"
  tanzu management-cluster kubeconfig get --admin --export-file /tmp/.kube-tkg/config

  echo "- Base64 encoding the management cluster's KUBECONFIG file contents"
  create_secret=true
  kubeconfig_contents=$(cat /tmp/.kube-tkg/config | base64 -w 0)
  echo "create_secret=$create_secret" >> $GITHUB_OUTPUT
  echo "kubeconfig_contents=$kubeconfig_contents" >> $GITHUB_OUTPUT

else
  echo "Validating base64 encoded KUBECONFIG contents for existing management cluster"

  echo "- Decoding the management cluster's KUBECONFIG contents and saving output to /tmp/.kube-tkg/config"
  mkdir -p /tmp/.kube-tkg
  echo "$3" | base64 -d > /tmp/.kube-tkg/config
  chmod 600 /tmp/.kube-tkg/config

  cluster_name=$(cat /tmp/.kube-tkg/config | yq '.clusters[].name')
  echo "- Management cluster name is [ $cluster_name ]"

  echo "- Logging in to management cluster"
  tanzu login --kubeconfig /tmp/.kube-tkg/config --context ${cluster_name}-admin@${cluster_name} --name ${cluster_name}

  if [ $(ls -1 *-overlay*.yml | wc -l) -gt 0 ] && [ $(yq '.KAPP_MANAGED' cluster.yml | wc -l) -eq 1 ]; then
    echo "-- Moving overlays into place"
    mkdir -p $HOME/.config/tanzu/tkg/providers/ytt/03_customizations/
    mv *-overlay*.yml $HOME/.config/tanzu/tkg/providers/ytt/03_customizations/
    echo "-- Reconciling any differences in cluster configuration"
    export _TKG_CLUSTER_FORCE_ROLE="management"
    tanzu cluster create $cluster_name --file cluster.yml --dry-run | kapp deploy --diff-changes --app $cluster_name --yes --file -

    rm -Rf /tmp/.kube-tkg
    mkdir -p /tmp/.kube-tkg
    echo "- Exporting management cluster's KUBECONFIG contents to file"
    tanzu management-cluster kubeconfig get --admin --export-file /tmp/.kube-tkg/config

    echo "- Base64 encoding the management cluster's KUBECONFIG file contents"
    create_secret=true
    kubeconfig_contents=$(cat /tmp/.kube-tkg/config | base64 -w 0)
    echo "create_secret=$create_secret" >> $GITHUB_OUTPUT
    echo "kubeconfig_contents=$kubeconfig_contents" >> $GITHUB_OUTPUT
  else
    echo "- Management cluster's KUBECONFIG file contents are valid"
    create_secret=false
    echo "create_secret=$create_secret" >> $GITHUB_OUTPUT
  fi
fi

rm -Rf /tmp/.kube-tkg $HOME/.config/tanzu
