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

# Install Tilt
brew install tilt

# Install GNU coreutils
brew install coreutils gnu-sed gnu-tar grep

## Add required exports to end of shell inits
declare -a shell_inits=( "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.config/fish/config.fish" )
mkdir -p $HOME/.config/fish
for si in "${shell_inits[@]}"
do
if [ ! -f "$si" ];then
  touch $si
fi
cat >> $si << EOF
export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:/opt/homebrew/opt/gnu-sed/libexec/gnubin:/opt/homebrew/opt/gnu-tar/libexec/gnubin:/opt/homebrew/opt/grep/libexec/gnubin:$PATH"
EOF
done