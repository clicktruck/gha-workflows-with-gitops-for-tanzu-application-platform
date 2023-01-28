#!/usr/bin/env bash
set -eox pipefail

# Set environment variables
export INSTALL_UP_CLI="false"
export INSTALL_UXP="true"
export CREATE_KIND="true"
export DESTROY_KIND="false"
export CROSSPLANE_GCP_PROVIDER_VERSION=0.22.0
export GOOGLE_PROJECT_ID="fe-cphillipson"
export GOOGLE_APPLICATION_CREDENTIALS=$HOME/.ssh/terraform@fe-cphillipson.iam.gserviceaccount.com.json
export GOOGLE_BUCKET_NAME="upbound-bucket-056852ee2"
export CREATE_GOOGLE_BUCKET="true"
export DELETE_GOOGLE_BUCKET="false"

cd /tmp

# Install Crossplane up CLI
if [ "$INSTALL_UP_CLI" == "true" ]; then
  curl -sL "https://cli.upbound.io" | sh
  sudo mv up /usr/lcoal/bin
fi

# Start single-node KinD cluster
if [ "$CREATE_KIND" == "true" ]; then
  kind create cluster
fi

# Install UXP into cluster
if [ "$INSTALL_UXP" == "true" ];then
  up uxp install
fi

# Wait 3 minutes
sleep 180

# Verify pods are up and running
kubectl get pods -n upbound-system

# Verify new resources are available
kubectl api-resources  | grep crossplane

# Install GCP provider
cat <<EOF | kubectl apply -f -
apiVersion: pkg.crossplane.io/v1
kind: Provider
metadata:
  name: upbound-provider-gcp
spec:
  package: xpkg.upbound.io/upbound/provider-gcp:v$CROSSPLANE_GCP_PROVIDER_VERSION
EOF

# Wait another 3 minutes
sleep 180

# Verify provider installed
kubectl get providers

# Install secret referencing GCP service account key JSON file
kubectl create secret \
generic gcp-secret \
-n upbound-system \
--from-file=creds=$GOOGLE_APPLICATION_CREDENTIALS

# Create provider config
cat <<EOF | kubectl apply -f -
apiVersion: gcp.upbound.io/v1beta1
kind: ProviderConfig
metadata:
  name: default
spec:
  projectID: $GOOGLE_PROJECT_ID
  credentials:
    source: Secret
    secretRef:
      namespace: upbound-system
      name: gcp-secret
      key: creds
EOF

# Create bucket name
if [ "$CREATE_GOOGLE_BUCKET" == "true" ]; then
cat <<EOF | kubectl apply -f -
apiVersion: storage.gcp.upbound.io/v1beta1
kind: Bucket
metadata:
  name: $GOOGLE_BUCKET_NAME
spec:
  forProvider:
    location: US
    storageClass: MULTI_REGIONAL
  providerConfigRef:
    name: default
  deletionPolicy: Delete
EOF
fi

# Wait 1 minute to create bucket
sleep 60

# Verify bucket created
kubectl get bucket

# Delete bucket name
if [ "$DELETE_GOOGLE_BUCKET" == "true" ]; then
  kubectl delete bucket $GOOGLE_BUCKET_NAME
fi

if [ "$DESTROY_KIND" == "true" ]; then
  kind delete cluster
  docker system prune -f
fi