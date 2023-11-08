#!/usr/bin/env bash

# Converts .tpl files in this package to .yml
# A .env file should be colocated in the same directory as this script with all environment variable values defined

if [ -f ".env" ]; then
  source .env
else
  echo " You forgot to provide a .env file with environment variable values set appropriately.  See .env.sample."
  exit 1
fi

# Convert .init/git-secrets.tpl to .init/git-secrets.yml
sed \
  -e "s/{{ .git_username }}/$GIT_USERNAME/g" \
  -e "s/{{ .git_personal_access_token }}/$GIT_PERSONAL_ACCESS_TOKEN/g" \
  .init/git-secrets.tpl > .init/git-secrets.yml


# Convert .init/scg-install-secrets.tpl to .init/scg-install-secrets.yml
sed \
  -e "s/{{ .scg_version }}/$SPRING_CLOUD_GATEWAY_VERSION/g" \
  -e "s/{{ .tanzu_network_username }}/$TANZU_NETWORK_USERNAME/g" \
  -e "s/{{ .tanzu_network_password }}/$TANZU_NETWORK_PASSWORD/g" \
  .init/scg-install-secrets.tpl > .init/scg-install-secrets.yml

# Convert .install/scg-install.tpl to .install/scg-install.yml
sed \
  -e "s~{{ .git_ref_name }}~$GIT_REF_NAME~g" \
  .install/scg-install.tpl > .install/scg-install.yml
