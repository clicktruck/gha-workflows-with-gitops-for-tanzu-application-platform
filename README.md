# Provisioning and Install Automation for Tanzu Application Platform

![Current State](https://img.shields.io/badge/current%20state-stable-brightgreen) ![Supported TAP release versions](https://img.shields.io/badge/versions%20supported-1.4,%201.5-blue)


## Table of Contents

* [Overview](#overview)
* [Benefits](#benefits)
* [Prerequisites](#prerequisites)
* [Getting Started](#getting-started)
* [Provisioning](#provisioning)
* [Installation](#installation)
* [Usage](#usage)


## Overview

:mega: _The content of this repository is not commercially supported by VMware. Any issues arising from the content or usage of this repository are your responsibility._

![Gitops for Tanzu Application Platform](docs/gitops-for-tap.png)

### Who is this for?

* Operators, SREs, Security and Compliance, Developers with some background in public cloud and Kubernetes


### How might you exercise it?

* In the context of evaluations, workshops, and PoCs


### Benefits

* For the community to perform quick evaluations
* Provisions all the underlying cloud infrastructure needed
  * e.g., Virtual networks, Kubernetes clusters, Container registries, DNS zones, Secrets management, Tools VM
* Installs either a single-cluster, full profile or multi-cluster (build, iterate, view and run profiles) installation of Tanzu Application Platform
* Useful for setup and delivery of workshops or PoCs in client environments by field engineering
  * Delivers a consistent experience for everyone involved

[Overview video (3:30)](https://studio.d-id.com/share?id=c821bcec6f9838f289f0fb73fca6237e&utm_source=copy)

## Prerequisites

### Account credentials

* [Github](https://github.com/)
* One or more on: [AWS](https://aws.amazon.com/), [Azure](https://azure.microsoft.com/en-us/), [Google Cloud](https://cloud.google.com/), [Oracle](https://www.oracle.com/cloud/)
* [Tanzu Network](https://network.pivotal.io)
* [VMware Marketplace](https://marketplace.cloud.vmware.com/)

### CLIs

* One or more of: [aws](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html), [az](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli), [gcloud](https://cloud.google.com/sdk/docs/install), [oci](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm)
* [docker](https://www.docker.com/products/docker-desktop/)
* [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
* [gh](https://github.com/cli/cli#installation)
* [packer](https://developer.hashicorp.com/packer/tutorials/docker-get-started/get-started-install-cli)
* [terraform](https://developer.hashicorp.com/terraform/downloads)

For your convenience a set of scripts exist to install a complement of the prerequisite toolset:

* [MacOS](scripts/install-prereqs-macos.sh) >= 10.15
* [Ubuntu](scripts/install-prereqs-linux.sh) >= 22.04
* [Windows](scripts/install-prereqs-windows.ps1) >= 10

However, if you already have Docker installed on your workstation or laptop, you might alternatively consider making use of this Docker [toolset image](docker/toolset-image/README.md).


## Getting started

Start by [forking this Github repository](https://docs.github.com/en/get-started/quickstart/fork-a-repo#forking-a-repository).  You're required to [configure your own set of Github secrets](https://github.com/Azure/actions-workflow-samples/blob/master/assets/create-secrets-for-GitHub-workflows.md) that will be leveraged by a collection of [Github Actions](.github/workflows).  Consult the _Configure Github Secrets_ section within each cloud target guide for the secrets to create.  For your convenience a script exists to make this easier to do from the command line (it depends on you having exported named environment variables). See [gh-set-secrets.sh](scripts/gh-set-secrets.sh).

If you're looking to contribute, clone your fork to your local workstation or laptop, [create a branch](https://git-scm.com/book/en/v2/Git-Branching-Basic-Branching-and-Merging) and get to work on that new feature.  This repo is open for [pull requests](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request).

| Branch name | TAP release version |
|-------------|---------------------|
| [main](https://github.com/pacphi/gha-workflows-with-gitops-for-tanzu-application-platform/tree/main) | 1.5.2 |
| [1.4.2](https://github.com/pacphi/gha-workflows-with-gitops-for-tanzu-application-platform/tree/1.4.2) | 1.4.2 |

To keep your fork up-to-date with upstream changes

```bash
git remote add upstream https://github.com/pacphi/gha-workflows-with-gitops-for-tanzu-application-platform
```
> Execute once


```bash
#! with git CLI
git fetch upstream
git merge upstream/main
git push

#! alternatively with gh CLI
gh repo sync --source pacphi/gha-workflows-with-gitops-for-tanzu-application-platform
```
> Execute periodically


## Provisioning

### With this repo

Provision the minimum set of cloud resources required for an installation

* [Microsoft Azure](docs/AZURE.md)
* [Amazon Web Services](docs/AWS.md)
* [Google Cloud Platform](docs/GOOGLE.md)
* [Oracle Cloud](docs/ORACLE.md)
* Tanzu Kubernetes Grid
  * [on AWS](docs/TKG-on-AWS.md)

### Elsewhere

* [Service Installer for VMware Tanzu](https://github.com/vmware-tanzu/service-installer-for-vmware-tanzu)
  > (Preferred) if you desire adherence to the [Tanzu Reference Architecture](https://docs.vmware.com/en/VMware-Tanzu/services/tanzu-reference-architecture/GUID-reference-designs-index.html)


## Installation

Want some TAP do you? There are a few pathways to achieve dial-tone, some more expedient than others.

### Preferred

* Initiate [install automation](docs/TAP.md) employing Github Action workflows targeting a cluster (or clusters)
  * Trigger a sample [set of dispatch workflows](docs/WORKFLOWS.md) from the command-line

### Manual

* Consult the public Tanzu Application Platform [installation documentation](https://docs.vmware.com/en/Tanzu-Application-Platform/1.5/tap/install-intro.html)

### Alternative

* Adopt a Gitops approach
  * via beta release of the [reference implementation](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.5/tap/install-gitops-intro.html)
  * via [this repository's implementation](gitops/README.md)


## Usage

Once you have successfully installed Tanzu Application Platform, you may wish to consult the following supplemental documentation:

* [Add or view Learning Center Workshops](docs/add-or-view-learningcenter-workshops/README.md)
* [Working with the bastion host](docs/working-with-the-bastion-host/README.md)
  * Configuring the Remote SSH VS Code plugin and [connecting to bastion host](docs/vscode-remote-ssh/README.md)
  * Configuring [remote live reload]((https://github.com/warroyo/future-blog/tree/main/TAP/remote-ssh-live-update)) with Tanzu Developer Toolkit targeting a containerized app deployed on a Kubernetes cluster
* Consider using Visual Studio Code as your IDE
  * Add [recommended extensions](https://code.visualstudio.com/docs/editor/extension-marketplace#_workspace-recommended-extensions) to your workspace
  * Setup [Remote development over SSH](https://code.visualstudio.com/docs/remote/ssh-tutorial)

Also be sure to checkout these guides:

* [Getting Started with the Tanzu Application Platform](https://docs.vmware.com/en/Tanzu-Application-Platform/1.5/tap/getting-started.html)
* [Getting started with multi-cluster Tanzu Application Platform](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.5/tap/multicluster-getting-started.html)
* [Configure and deploy to multiple environments with custom parameters](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.5/tap/scc-config-deploy-multi-env.html)

Companion repositories:

* [Accelerator samples](https://github.com/vmware-tanzu/application-accelerator-samples) use to bootstrap greenfield projects
* [Curated sample applications](https://github.com/pacphi/tap-sample-apps) use to demonstrate deploying workloads with [kapp](https://carvel.dev/kapp/) and [ytt](https://carvel.dev/ytt/)