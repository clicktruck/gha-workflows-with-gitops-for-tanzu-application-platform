#!/bin/bash

# Install Homebrew; @see https://brew.sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

# Install Packer
brew install packer

# Install Terraform
brew install terraform

# Install Git
brew install git

# Install Github CLI
brew install gh

# Install Docker
brew install --cask docker

# Install AWS CLI
brew install awscli

# Install Azure CLI
brew install azure-cli

# Install Google Cloud CLI
echo "Visit https://cloud.google.com/sdk/docs/install-sdk#mac and follow instructions to install Google Cloud SDK"

# Install VSCode
brew install --cask visual-studio-code
