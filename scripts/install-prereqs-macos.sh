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
echo "Visit https://www.docker.com/products/docker-desktop/ and download the .dmg file using the Apple Chip link, then install by double-clicking on the .dmg file, then drag-and-drop the app into the Applications folder to install Docker Desktop"

# Install AWS CLI
brew install awscli

# Install Azure CLI
brew install azure-cli

# Install Google Cloud CLI
echo "Visit https://cloud.google.com/sdk/docs/install-sdk#mac and follow instructions to install Google Cloud SDK"

# Install Oracle Cloud CLI
brew install oci-cli

# Install VSCode
brew install --cask visual-studio-code
