#!/usr/bin/env bash

# Converts .tpl files in this package to .yml
# A .env file should be colocated in the same directory as this script with all environment variable values defined

if [ -f ".env" ]; then
  source .env
else
  echo " You forgot to provide a .env file with environment variable values set appropriately.  See .env.sample."
  exit 1
fi

# Convert .init/tas-adapter-install-config.tpl to .init/tas-adapter-install-config.yml
sed \
  -e "s/{{ .app_name }}/$APP_NAME/g" \
  -e "s~{{ .container_image_registry_url }}~$CONTAINER_IMAGE_REGISTRY_URL~g" \
  -e "s~{{ or .container_image_registry_prefix \"tas-adapter\" }}~$CONTAINER_IMAGE_REGISTRY_PREFIX~g" \
  -e "s/{{ .domain }}/$DOMAIN/g" \
  .init/tas-adapter-install-config.tpl > .init/tas-adapter-install-config.yml


# Convert .init/tas-adapter-install-secrets.tpl to .init/tas-adapter-install-secrets.yml
sed \
  -e "s/{{ .app_name }}/$APP_NAME/g" \
  -e "s~{{ or .cf_admin_username \"\" }}~$CF_ADMIN_USERNAME~g" \
  -e "s/{{ .tanzu_network_username }}/$TANZU_NETWORK_USERNAME/g" \
  -e "s/{{ .tanzu_network_password }}/$TANZU_NETWORK_PASSWORD/g" \
  -e "s~{{ or .aws_iam_role_arn_for_ecr \"\" }}~$AWS_IAM_ROLE_ARN_FOR_ECR~g" \
  .init/tas-adapter-install-secrets.tpl > .init/tas-adapter-install-secrets.yml

# Convert .install/tas-adapter-install.tpl to .install/tas-adapter-install.yml
sed \
  -e "s/{{ .app_name }}/$APP_NAME/g" \
  -e "s~{{ .git_ref_name }}~$GIT_REF_NAME~g" \
  .install/tas-adapter-install.tpl > .install/tas-adapter-install.yml
