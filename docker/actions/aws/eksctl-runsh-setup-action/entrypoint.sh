#!/usr/bin/env bash

# Entrypoint for eksctlh-setup-action

# This script expects that the following environment variables have been set:
#
# * AWS_ACCESS_KEY_ID
# * AWS_SECRET_ACCESS_KEY
#
# If you intend to run this script as the ENTRYPOINT in a Docker file then pass
# each of the environment variables above with -e (e.g., -e AWS_ACCESS_KEY_ID=xxx).
#
# If you intend to run this script standalone then you will need to export each of
# the environment variables above (e.g., export AWS_ACCESS_KEY_ID=xxx) beforehand.

if [ x"${AWS_ACCESS_KEY_ID}" == "x" ] || [ x"${AWS_SECRET_ACCESS_KEY}" == "x" ]; then
  echo "Expected AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY enviroment variables to have been set!"
  exit 1;
fi

if [ x"${AWS_SESSION_TOKEN}" == "x" ]; then
  echo "Session token not supplied."
else
  echo "Session token supplied."
fi

echo "Validate eksctl CLI."
eksctl version

echo "Executing script."
echo "$1" | base64 -d > run.sh
chmod +x run.sh
read -r -a args <<< "$2"
. ./run.sh ${args[@]}
