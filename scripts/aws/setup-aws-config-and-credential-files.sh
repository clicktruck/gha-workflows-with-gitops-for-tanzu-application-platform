#!/usr/bin/env bash

# Update AWS Configuration and Credentials
# Warning! Overwrites existing $HOME/.aws/config and $HOME/.aws/credentials files

# Make sure top-level directory exists
mkdir -p $HOME/.aws

# Exit if expected environment variables have not been set prior to script execution
if [ x"${AWS_ACCESS_KEY_ID}" == "x" ] || [ x"${AWS_SECRET_ACCESS_KEY}" == "x" ]; then
  echo "Expected AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY enviroment variables to have been set!"
  exit 1;
fi

if [ x"${AWS_REGION}" == "x" ]; then
  echo "Expected AWS_REGION environment variable to have been set!"
  exit 1;
fi

if [ x"${AWS_SESSION_TOKEN}" == "x" ]; then
  echo "Session token not supplied."
else
  echo "Session token supplied."
fi

# Use enviroment variables to construct files

echo "Writing contents into $HOME/.aws/config"
cat > $HOME/.aws/config << EOF
[default]
region=$AWS_REGION
output=json
cli_history = enabled
cli_pager=
cli_timestamp_format = iso8601
EOF

echo "Writing contents into $HOME/.aws/credentials"
if [ -z "$AWS_SESSION_TOKEN" ]; then
cat > $HOME/.aws/credentials << EOF
[default]
aws_access_key_id=$AWS_ACCESS_KEY_ID
aws_secret_access_key=$AWS_SECRET_ACCESS_KEY
EOF
else
cat > $HOME/.aws/credentials << EOF
[default]
aws_access_key_id=$AWS_ACCESS_KEY_ID
aws_secret_access_key=$AWS_SECRET_ACCESS_KEY
aws_session_token=$AWS_SESSION_TOKEN
EOF
fi

echo "Here you go!"
ls -la $HOME/.aws
