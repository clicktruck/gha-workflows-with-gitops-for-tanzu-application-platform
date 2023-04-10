#!/usr/bin/env bash

set -x

# This script influences the execution of /scripts/install-package.sh

# It will:

# * aquire a token from the metadata-store-read-write-client secret
# * update secret named metadata-store-token, plumbing the token value
# * employ kctrl app kick to make the Apps aware of new configuration (i.e., the token)

# Only execute for TAP full and view profiles!
ACTIVE_PROFILE=$(yq '.spec.template.[].ytt.paths[0]' tap-post-install.yml | rev | cut -d/ -f1 | rev)

if [ "$ACTIVE_PROFILE" == "full" ] || [ "$ACTIVE_PROFILE" == "view" ]; then

# Aquire token for TAP GUI access to Metadata Store
# Fetch from secret as described here https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.5/tap/scst-store-create-service-account.html#readwrite-service-account-4
TOKEN=$(kubectl get secrets metadata-store-read-write-client -n metadata-store -o jsonpath="{.data.token}" | base64 -d)

# This value is referenced in gitops/tanzu/application-platform/profiles/base/{profile}/tap-values-{profile}.yml
cat <<EOF >metadata-store-tap-gui-auth-token.yml
#@ load("@ytt:yaml", "yaml")
---
#@ def config():
tap:
  gui:
    proxy:
      metadata_store:
        token: ${TOKEN}
#@ end
---
apiVersion: v1
kind: Secret
metadata:
  name: metadata-store-token
  namespace: tap-install-gitops
stringData:
  metadata-store-tap-gui-auth-token.yml: #@ yaml.encode(config())
EOF

kubectl apply -f <(ytt -f metadata-store-tap-gui-auth-token.yml)

# Remove secret file from file-system
rm -f metadata-store-tap-gui-auth-token.yml


# Let's kick the App whose responsible for resources consuming the token
kctrl app kick -a tap-${ACTIVE_PROFILE} -n tap-install-gitops -y

fi