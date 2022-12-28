#!/usr/bin/env bash

set -eox pipefail

MAX_OBSERVED_CLUSTERS=5

## This script onboards up to MAX_OBSERVED_CLUSTERS clusters to be observed by App Live View hosted on a cluster
## where Tanzu Application Platform is installed with the View profile

######

## Target
## - TAP view profile cluster

## Inputs
## - Name
## - Kubeconfig of cluster to be observed

## Pass above as base64-encoded YAML map. (Input name: observed-clusters).

## Therefore one additional input in dispatch workflow. Onboard up to MAX_OBSERVED_CLUSTERS clusters.
## If multiple, opt for replacing secret with previously onboarded clusters.

## Input could be any cluster on any cloud managed or K8s provider.
## (Management of secret out of band, possibly post cluster provision request).

## Do the work to fetch outputs.

## Outputs
## - Name
## - URL
## - Token
## - SkipTLS

## Output will actually be a block of configuration (i.e., an array-map)

## Exception handling

## a) Avoid collision with previously onboarded clusters by fetching and base64-decodings existing secret?
## Count clusters, add next. Index starting with 1.

## b) Overwrite config for cluster with same name? Yes.

## c) We only have value placeholders for up to N clusters. Fail onboarding if we attempt to add N+1.

## Extension

## We have a YTT template (.yml) and Go-template secrets (.tpl) managed in Git.
## One could add support for observing more than MAX_OBSERVED_CLUSTERS clusters by making appropriate additions to each.

## Essentially updating secret used by App CR previously deployed targeting View profile cluster.

######

## Assumes the following CLIs are installed:
## * kubectl
## * cloud provider (e.g., aws, gcloud)
## * jq
## * yq

## Do not change anything below unless you know what you're doing!

indent6() { sed 's/^/      /'; }

if [ -z "$1" ] && [ -z "$2" ]; then
	echo "Usage: observe-clusters.sh {base64-encoded-yaml-configuration} {base64-encoded-kubeconfig-contents}"
	exit 1
fi

YAML_CONFIG_CONTENTS="$1"
KUBECONFIG_CONTENTS="$2"

if [ -z "$GITHUB_WORKSPACE" ]; then
  GITOPS_DIR=../gitops/tanzu/application-platform/.init
else
  GITOPS_DIR=$GITHUB_WORKSPACE/gitops/tanzu/application-platform/.init
fi
OBSERVED_CLUSTERS_BLOCK_CONTENTS=$GITOPS_DIR/observed-clusters-config.tpl

mkdir -p /tmp/.kube
echo "$KUBECONFIG_CONTENTS" | base64 --decode > /tmp/.kube/config

echo "$YAML_CONFIG_CONTENTS" | base64 --decode > /tmp/clusters.yml
INDEXED_CONFIG=/tmp/indexed_clusters.yml
yq 'to_entries | from_entries' /tmp/clusters.yml > $INDEXED_CONFIG
array_length=$(yq 'length' $INDEXED_CONFIG)
if [ "$array_length" -gt "$MAX_OBSERVED_CLUSTERS" ]; then
  echo "Too many clusters to be onboarded.  Maximum number is $MAX_OBSERVED_CLUSTERS."
  exit 1
fi

# CAUTION: when more than one cluster supplied overwrites any existing clusters that were under observation
if [ "$array_length" -gt "1" ]; then
  # This dynamically created YAML block will be added to tap-install-secrets.tpl at {{ .observed_clusters_block }}
  echo "  observed:" > $OBSERVED_CLUSTERS_BLOCK_CONTENTS
  echo "    clusters:" >> $OBSERVED_CLUSTERS_BLOCK_CONTENTS

  for ((i=0; i <$array_length; i++))
  do
    # Get cluster name
    f=$(yq ".$i.name" $INDEXED_CONFIG)
    # Get cluster provider
    cp=$(yq ".$i.cluster-provider" $INDEXED_CONFIG)
    # Get and decode base64-encoded .kube/config file contents
    yq ".$i.base64-encoded-kubeconfig-contents" $INDEXED_CONFIG | base64 --decode > /tmp/$f-config.yml
    # Set required auth environment variables based upon cluster provider
    case "$cp" in
      aks | tkg)
        ;;
      eks)
        export AWS_ACCESS_KEY_ID=$(yq ".$i.credentials.aws-access-key-id" $INDEXED_CONFIG)
        export AWS_SECRET_ACCESS_KEY=$(yq ".$i.credentials.aws-secret-access-key" $INDEXED_CONFIG)
        export AWS_SESSION_TOKEN=$(yq ".$i.credentials.aws-session-token" $INDEXED_CONFIG)
        if [ "${AWS_SESSION_TOKEN}" == "null" ]; then
          echo "No session token provided for $f"
          unset AWS_SESSION_TOKEN
        fi
        export AWS_REGION=$(yq ".$i.credentials.aws-region" $INDEXED_CONFIG)
        ;;
      gke)
        jc=$(yq ".$i.credentials.base64-encoded-google-service-account-json-file-contents" $INDEXED_CONFIG | base64 --decode)
        echo "$jc" > /tmp/google-service-account-credentials.json
        export GOOGLE_APPLICATION_CREDENTIALS="/tmp/google-service-account-credentials.json"
        ;;
    esac
    # Target cluster
    export KUBECONFIG="/tmp/$f-config.yml"
    # Fetch URL and token from target cluster
    CLUSTER_URL=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')
    TOKEN_NAME=$(kubectl -n tap-gui get sa tap-gui-viewer -o=json | jq -r '.secrets[0].name')
    if [ "${TOKEN_NAME}" == "null" ]; then
      kubectl apply --wait=true -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: tap-gui-viewer
  namespace: tap-gui
  annotations:
    kubernetes.io/service-account.name: tap-gui-viewer
type: kubernetes.io/service-account-token
EOF
      CLUSTER_TOKEN=$(kubectl -n tap-gui get secret tap-gui-viewer -o=json | jq -r '.data["token"]' | base64 -d)
    else
      CLUSTER_TOKEN=$(kubectl -n tap-gui get secret $TOKEN_NAME -o=json | jq -r '.data["token"]' | base64 -d)
    fi
    echo CLUSTER_URL: $CLUSTER_URL
    echo CLUSTER_TOKEN: $CLUSTER_TOKEN
    # Configure the Kubernetes client to verify the TLS certificates presented by a cluster’s API server
    CLUSTER_CA_CERTIFICATES=$(kubectl config view --raw -o jsonpath='{.clusters[0].cluster.certificate-authority-data}')
    echo CLUSTER_CA_CERTIFICATES: $CLUSTER_CA_CERTIFICATES
    # Reconcile config if there are existing clusters under observation
    # Don't overwrite if only one cluster's config was supplied
    if [ "$array_length" -eq "1" ]; then
      export KUBECONFIG=/tmp/.kube/config
      TAP_INSTALL_SECRET=/tmp/tap-values.yml
      kubectl get secret tap-values -n tap-install -o 'go-template={{index .data "values.yml"}}' | base64 -d > $TAP_INSTALL_SECRET
      clusters_observed=$(yq ".tap.observed.clusters | length" $TAP_INSTALL_SECRET)
      new_index="$((clusters_observed + 1))"
      if [ "$new_index" -gt "$MAX_OBSERVED_CLUSTERS" ]; then
        echo "Cannot onboard another cluster because current template supports up to $MAX_OBSERVED_CLUSTERS clusters and $MAX_OBSERVED_CLUSTERS are already under observation."
        exit 1
      fi
      yq '.tap.observed.clusters' /tmp/tap-values.yml | indent6 > $OBSERVED_CLUSTERS_BLOCK_CONTENTS
      echo "      kv$new_index:" >> $OBSERVED_CLUSTERS_BLOCK_CONTENTS
    else
      j="$((i + 1))"
      echo "      kv$j:" >> $OBSERVED_CLUSTERS_BLOCK_CONTENTS
    fi
    echo "        name: $f" >> $OBSERVED_CLUSTERS_BLOCK_CONTENTS
    echo "        url: $CLUSTER_URL" >> $OBSERVED_CLUSTERS_BLOCK_CONTENTS
    echo "        token: $CLUSTER_TOKEN" >> $OBSERVED_CLUSTERS_BLOCK_CONTENTS
    echo "        skipTLS: false" >> $OBSERVED_CLUSTERS_BLOCK_CONTENTS
    echo "        skipMetrics: true" >> $OBSERVED_CLUSTERS_BLOCK_CONTENTS
    echo "        ca: $CLUSTER_CA_CERTIFICATES" >> $OBSERVED_CLUSTERS_BLOCK_CONTENTS
  done
fi
