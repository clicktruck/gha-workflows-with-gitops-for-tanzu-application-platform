#!/usr/bin/env bash

# Install Oracle CLI
if [ "x${OCI_CLI_VERSION}" == "x" ]; then
  OCI_CLI_VERSION=3.31.0
fi

curl -LO https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh
chmod +x install.sh
./install.sh --accept-all-defaults --oci-cli-version ${OCI_CLI_VERSION}
