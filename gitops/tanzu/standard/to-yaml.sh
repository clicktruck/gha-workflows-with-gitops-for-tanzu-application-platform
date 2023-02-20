#!/usr/bin/env bash

# Converts .tpl files in this package to .yml
# A .env file should be colocated in the same directory as this script with all environment variable values defined

if [ -f ".env" ]; then
  source .env
else
  echo " You forgot to provide a .env file with environment variable values set appropriately.  See .env.sample."
  exit 1
fi

# Convert .init/standard-install-config.tpl to .init/standard-install-config.yml
sed \
  -e "s/{{ .tkg_version }}/$TKG_VERSION/g" \
  .init/standard-install-config.tpl > .init/standard-install-config.yml

# Convert .init/standard-install-secrets.tpl to .init/standard-install-secrets.yml
sed \
  -e "s/{{ .git_ssh_private_key }}/$GIT_SSH_PRIVATE_KEY/g" \
  -e "s/{{ .git_ssh_known_hosts }}/$GIT_SSH_KNOWN_HOSTS/g" \
  -e "s/{{ .tanzu_network_username }}/$TANZU_NETWORK_USERNAME/g" \
  -e "s/{{ .tanzu_network_password }}/$TANZU_NETWORK_PASSWORD/g" \
  .init/standard-install-secrets.tpl > .init/standard-install-secrets.yml

# Convert .install/standard-install.tpl to .install/standard-install.yml
sed \
  -e "s~{{ .git_ref_name }}~$GIT_REF_NAME~g" \
  .install/standard-install.tpl > .install/standard-install.yml
