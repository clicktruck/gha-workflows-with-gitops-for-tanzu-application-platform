#!/bin/bash -e

main() {
  # @see https://github.com/hashicorp/packer/issues/2639
  /usr/bin/cloud-init status --wait

  # Manage software versions installed here
  TZ=America/Los_Angeles
  ARGO_VERSION=3.4.5
  ARGOCD_VERSION=2.6.7
  BOSH_VERSION=7.2.2
  CF_VERSION=8.6.1
  CREDHUB_VERSION=2.9.13
  HELM_VERSION=3.11.3
  HELMFILE_VERSION=0.152.0
  AWS_IAM_AUTHENTICATOR_VERSION=0.6.2
  IMGPKG_VERSION=0.36.0
  KAPP_VERSION=0.55.0
  KBLD_VERSION=0.37.0
  KCTRL_VERSION=0.45.0
  KIND_VERSION=0.18.0
  KPACK_CLI_VERSION=0.10.0
  KWT_VERSION=0.0.6
  KUBECTL_VERSION=1.24.9
  KNATIVE_VERSION=1.9.2
  LEFTOVERS_VERSION=0.62.0
  OCI_CLI_VERSION=3.25.4
  OM_VERSION=7.9.0
  MKPCLI_VERSION=0.15.1
  PINNIPED_VERSION=0.22.0
  PIVNET_VERSION=3.0.1
  RELOK8S_VERSION=0.5.2
  SOPS_VERSION=3.7.3
  TEKTONCD_VERSION=0.30.0
  TERRAFORM_VERSION=1.4.5
  TERRAFORM_DOCS_VERSION=0.16.0
  TMC_VERSION=0.5.3-88d04e82
  VELERO_VERSION=1.11.0
  VENDIR_VERSION=0.33.1
  YTT_VERSION=0.45.0

  # Place ourselves in a temporary directory; don't clutter user.home directory w/ downloaded artifacts
  cd /tmp

  # Set timezone
  ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

  # Bring OS package management up-to-date
  apt update -y
  apt upgrade -y

  # Install packages from APT
  apt install build-essential curl default-jre git golang-go gpg graphviz gzip httpie libnss3-tools jq openssl pv python3-pip python3-dev python3-venv ruby-dev snapd sudo tmux tree tzdata unzip wget -y
  apt install apt-transport-https ca-certificates gnupg lsb-release software-properties-common dirmngr vim -y
  add-apt-repository ppa:cncf-buildpacks/pack-cli
  apt install pack-cli -y

  # Install packages from Snap
  sudo snap install snap-store
  sudo snap install k9s
  sudo snap install cvescan

  # Install Github CLI
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
  sudo apt update
  sudo apt install gh -y

  # Install NodeJS
  curl -fsSL https://deb.nodesource.com/setup_19.x | sudo -E bash -
  sudo apt-get install -y nodejs

  # Install Python 3
  python3 -m pip install --user --upgrade pip
  python3 -m pip install --user virtualenv

  # Install eksctl
  curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
  sudo mv /tmp/eksctl /usr/local/bin

  # Install Docker-CE
  useradd -m docker && echo "docker:docker" | chpasswd
  adduser docker sudo
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  echo \
    "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io
  sudo usermod -aG docker ubuntu
  sudo systemctl enable docker.service
  sudo systemctl enable containerd.service
  docker run --rm hello-world

  # Install AWS CLI
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  sudo ./aws/install

  # Install AWS IAM Authenticator
  curl -Lo aws-iam-authenticator https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v${AWS_IAM_AUTHENTICATOR_VERSION}/aws-iam-authenticator_${AWS_IAM_AUTHENTICATOR_VERSION}_linux_amd64
  chmod +x aws-iam-authenticator
  sudo mv aws-iam-authenticator /usr/local/bin

  # Install Azure CLI
  curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

  # Install Google Cloud SDK
  echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
  curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
  apt update -y && apt install google-cloud-cli google-cloud-sdk-gke-gcloud-auth-plugin -y

  # Install Oracle Cloud CLI
  curl -LO https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh
  chmod +x install.sh
  ./install.sh --accept-all-defaults --oci-cli-version ${OCI_CLI_VERSION}

  # Install Cloud Foundry UAA CLI
  gem install cf-uaac

  # Install BOSH CLI
  wget https://github.com/cloudfoundry/bosh-cli/releases/download/v${BOSH_VERSION}/bosh-cli-${BOSH_VERSION}-linux-amd64
  mv bosh-cli-${BOSH_VERSION}-linux-amd64 bosh
  chmod +x bosh
  sudo mv bosh /usr/local/bin

  # Install Cloud Foundry CLI
  wget -O cf.tgz "https://packages.cloudfoundry.org/stable?release=linux64-binary&version=${CF_VERSION}&source=github-rel"
  tar -xvf cf.tgz
  rm -Rf cf.tgz
  sudo cp cf8 /usr/local/bin/cf

  # Install Credhub CLI
  wget https://github.com/cloudfoundry/credhub-cli/releases/download/${CREDHUB_VERSION}/credhub-linux-${CREDHUB_VERSION}.tgz
  tar -xvzf credhub-linux-${CREDHUB_VERSION}.tgz
  rm -Rf credhub-linux-${CREDHUB_VERSION}.tgz
  sudo mv credhub /usr/local/bin

  # Install kubectl
  curl -LO https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl
  chmod +x kubectl
  sudo mv kubectl /usr/local/bin

  # Install Knative
  curl -L -o kn https://github.com/knative/client/releases/download/knative-v${KNATIVE_VERSION}/kn-linux-amd64
  chmod +x kn
  sudo mv kn /usr/local/bin

  # Install Operations Manager CLI (for Cloud Foundry)
  wget https://github.com/pivotal-cf/om/releases/download/${OM_VERSION}/om-linux-amd64-${OM_VERSION}
  mv om-linux-amd64-${OM_VERSION} om
  chmod +x om
  sudo mv om /usr/local/bin

  # Install Tanzu Network CLI (formerly Pivotal Network CLI)
  wget https://github.com/pivotal-cf/pivnet-cli/releases/download/v${PIVNET_VERSION}/pivnet-linux-amd64-${PIVNET_VERSION}
  mv pivnet-linux-amd64-${PIVNET_VERSION} pivnet
  chmod +x pivnet
  sudo mv pivnet /usr/local/bin

  # Install Terraform
  wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
  unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip
  rm -f terraform_${TERRAFORM_VERSION}_linux_amd64.zip
  sudo mv terraform /usr/local/bin

  # Install Terraform-Docs
  curl -Lo ./terraform-docs https://github.com/segmentio/terraform-docs/releases/download/v${TERRAFORM_DOCS_VERSION}/terraform-docs-v${TERRAFORM_DOCS_VERSION}-$(uname | tr '[:upper:]' '[:lower:]')-amd64
  chmod +x ./terraform-docs
  sudo mv terraform-docs /usr/local/bin

  # Install leftovers - helps to clean up orphaned resources created in a public cloud
  wget https://github.com/genevieve/leftovers/releases/download/v${LEFTOVERS_VERSION}/leftovers-v${LEFTOVERS_VERSION}-linux-amd64
  mv leftovers-v${LEFTOVERS_VERSION}-linux-amd64 leftovers
  chmod +x leftovers
  sudo mv leftovers /usr/local/bin

  # Install Tanzu Mission Control CLI
  curl -LO https://tmc-cli.s3-us-west-2.amazonaws.com/tmc/${TMC_VERSION}/linux/x64/tmc
  chmod +x tmc
  sudo mv tmc /usr/local/bin

  # Install Helm
  curl -LO "https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz"
  tar -xvf helm-v${HELM_VERSION}-linux-amd64.tar.gz
  sudo mv linux-amd64/helm /usr/local/bin

  # Install Helmfile
  curl -LO "https://github.com/helmfile/helmfile/releases/download/v${HELMFILE_VERSION}/helmfile_${HELMFILE_VERSION}_linux_amd64.tar.gz"
  tar -xvf helmfile_${HELMFILE_VERSION}_linux_amd64.tar.gz
  sudo mv helmfile /usr/local/bin


  # Install full complement of Carvel toolset
  wget -O imgpkg https://github.com/vmware-tanzu/carvel-imgpkg/releases/download/v${IMGPKG_VERSION}/imgpkg-linux-amd64
  chmod +x imgpkg
  sudo mv imgpkg /usr/local/bin
  wget -O ytt https://github.com/vmware-tanzu/carvel-ytt/releases/download/v${YTT_VERSION}/ytt-linux-amd64
  chmod +x ytt
  sudo mv ytt /usr/local/bin
  wget -O vendir https://github.com/vmware-tanzu/carvel-vendir/releases/download/v${VENDIR_VERSION}/vendir-linux-amd64
  chmod +x vendir
  sudo mv vendir /usr/local/bin
  wget -O kapp https://github.com/vmware-tanzu/carvel-kapp/releases/download/v${KAPP_VERSION}/kapp-linux-amd64
  chmod +x kapp
  sudo mv kapp /usr/local/bin
  wget -O kbld https://github.com/vmware-tanzu/carvel-kbld/releases/download/v${KBLD_VERSION}/kbld-linux-amd64
  chmod +x kbld
  sudo mv kbld /usr/local/bin
  wget -O kwt https://github.com/vmware-tanzu/carvel-kwt/releases/download/v${KWT_VERSION}/kwt-linux-amd64
  chmod +x kwt
  sudo mv kwt /usr/local/bin
  wget -O kctrl https://github.com/vmware-tanzu/carvel-kapp-controller/releases/download/v${KCTRL_VERSION}/kctrl-linux-amd64
  chmod +x kctrl
  sudo mv kctrl /usr/local/bin

  # Install Minio CLI
  curl -LO https://dl.min.io/client/mc/release/linux-amd64/mc
  chmod +x mc
  sudo mv mc /usr/local/bin

  # Install Argo CD and Argo Workflows CLIs
  wget -O argocd https://github.com/argoproj/argo-cd/releases/download/v${ARGOCD_VERSION}/argocd-linux-amd64
  chmod +x argocd
  sudo mv argocd /usr/local/bin
  curl -sLO https://github.com/argoproj/argo-workflows/releases/download/v${ARGO_VERSION}/argo-linux-amd64.gz
  gunzip argo-linux-amd64.gz
  chmod +x argo-linux-amd64
  sudo mv argo-linux-amd64 /usr/local/bin/argo

  # Install Tekton CD CLI
  curl -LO https://github.com/tektoncd/cli/releases/download/v${TEKTONCD_VERSION}/tkn_${TEKTONCD_VERSION}_Linux_x86_64.tar.gz
  tar -xvf tkn_${TEKTONCD_VERSION}_Linux_x86_64.tar.gz
  chmod +x tkn
  sudo mv tkn /usr/local/bin

  # Install mkcert
  git clone https://github.com/FiloSottile/mkcert && cd mkcert
  go build -ldflags "-X main.Version=$(git describe --tags)"
  sudo mv mkcert /usr/local/bin
  cd ..
  rm -Rf mkcert

  # Install kpack-cli
  curl -Lo ./kp https://github.com/vmware-tanzu/kpack-cli/releases/download/v${KPACK_CLI_VERSION}/kp-linux-${KPACK_CLI_VERSION}
  chmod +x ./kp
  sudo mv ./kp /usr/local/bin

  # Install kind
  curl -Lo ./kind https://kind.sigs.k8s.io/dl/v${KIND_VERSION}/kind-linux-amd64
  chmod +x ./kind
  sudo mv ./kind /usr/local/bin

  # Install Velero
  curl -LO https://github.com/vmware-tanzu/velero/releases/download/v${VELERO_VERSION}/velero-v${VELERO_VERSION}-linux-amd64.tar.gz
  tar -xvf velero-v${VELERO_VERSION}-linux-amd64.tar.gz
  chmod +x velero-v${VELERO_VERSION}-linux-amd64/velero
  sudo mv velero-v${VELERO_VERSION}-linux-amd64/velero /usr/local/bin

  # Install VMware Labs Marketplace CLI
  curl -LO https://github.com/vmware-labs/marketplace-cli/releases/download/v${MKPCLI_VERSION}/mkpcli-linux-amd64.tgz
  tar -xvf mkpcli-linux-amd64.tgz
	chmod +x mkpcli
	sudo mv mkpcli /usr/local/bin

  # Install cmctl; @see https://cert-manager.io/docs/usage/cmctl/
  curl -L -o cmctl.tar.gz https://github.com/jetstack/cert-manager/releases/latest/download/cmctl-linux-amd64.tar.gz
  tar xzf cmctl.tar.gz
  sudo mv cmctl /usr/local/bin

  # Install relok8s
  curl -LO https://github.com/vmware-tanzu/asset-relocation-tool-for-kubernetes/releases/download/v${RELOK8S_VERSION}/relok8s_${RELOK8S_VERSION}_linux_x86_64.tar.gz
  tar -xvf relok8s_${RELOK8S_VERSION}_linux_x86_64.tar.gz
  chmod +x relok8s
  sudo mv relok8s /usr/local/bin

  # Install Mozilla Secrets for Operations
  curl -LO https://github.com/mozilla/sops/releases/download/v${SOPS_VERSION}/sops-v${SOPS_VERSION}.linux.amd64
  mv sops-v${SOPS_VERSION}.linux.amd64 sops
  chmod +x sops
  sudo mv sops /usr/local/bin

  # Install pinniped
  curl -Lso pinniped https://get.pinniped.dev/v${PINNIPED_VERSION}/pinniped-cli-linux-amd64
  chmod +x pinniped
  sudo mv pinniped /usr/local/bin

  # Install yq
  sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
  sudo chmod a+x /usr/local/bin/yq

  # Clean-up APT cache
  rm -Rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
  apt clean

  cd /home/ubuntu

  # Move Tanzu CLI into place (if it had been file provisioned)
  if [ -e "/home/ubuntu/tanzu" ]; then
    sudo mv /home/ubuntu/tanzu /usr/local/bin
  fi

  if [ -e "/home/ubuntu/tanzu-cli-bundle-linux-amd64.tar.gz" ]; then
    tar xvf tanzu-cli-bundle-linux-amd64.tar.gz -C .
  fi

}

main
