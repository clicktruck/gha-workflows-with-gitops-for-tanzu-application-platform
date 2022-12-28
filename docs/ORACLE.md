# Oracle Cloud Provisioning Automation for Tanzu Application Platform

> **Warning** Github Actions workflows have not yet been implemented.  Terraform module implementation is also incomplete.  Some links may be broken.

## Table of Contents

* [Benefits](#benefits)
* [What does it do?](#what-does-it-do)
* [Prerequisites](#prerequisites)
  * [Fork this repository](#fork-this-repository)
  * [Increase Oracle Cloud Quotas](#increase-oracle-cloud-quotas)
  * [(Optional) Setup an Oracle Cloud service principal](#optional-setup-an-oracle-cloud-service-principal)
  * [Upload Public key](#upload-public-key)
  * [Setup a Github SSH key-pair](#setup-a-github-ssh-key-pair)
  * [Setup a Personal Access Token in Github](#setup-a-personal-access-token-in-github)
  * [Configure Github Secrets](#configure-github-secrets)
  * [Create KMS Key](#create-kms-key)
  * [Create Remote Backend Support](#create-remote-backend-support)
  * [Create Toolset Image](#create-toolset-image)
* [How do I use this?](#how-do-i-use-this)
  * [Fast path](#fast-path)
  * [Slow path](#slow-path)
    * [Modules](#modules)
* [Vending credentials](#vending-credentials)
* [Cleaning up everything](#cleaning-up-everything)


## Benefits

This repository provides provisioning automation targeting [Oracle Cloud](https://www.oracle.com/cloud/).


## What does it do?

It provisions the minimum set of cloud resources needed to begin installing Tanzu Application Platform on Oracle Cloud.


## Prerequisites

### Fork this repository

You will want to fork this GitHub repository and enable the GitHub Actions it contains.

### Increase Oracle Cloud Quotas

There are a few Oracle Cloud default [quotas](https://cloud.oracle.com/limits) that may need to be adjusted.

1. VM instances

Choose the region and set the limit to >= 30 in your request.

> Note:  The above quotas will be enough to deploy the infrastructure needed for installing TAP.  Individual mileage may vary depending on existing resources.

### (Optional) Setup an Oracle Cloud service principal

First, authenticate to Oracle Cloud.

> Do this only if you are planning on running Terraform scripts locally with an IAM user

```bash
oci setup config
```

You will be prompted for

* User OCID
  * to be found under [Profile > User Settings](https://cloud.oracle.com/identity/users)
* Tenancy OCID
  * to be found under [Profile > Tenancy: {account_name}](https://cloud.oracle.com/tenancy)
* Key file directory
  * just accept the default location
* Region
  * you will be prompted with several options

You will need to upload a public key.

### Upload Public key

From the hamburger menu in the upper left-hand corner, visit `Identity & Security > Users`.  Then click on a user.  Then click on `Resources > API Keys`.  Finally, click on the `Add API Key` button and follow the prompts to complete uploading your public key (.pem) file.

> See [How to Upload the Public Key](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#How2)

### Setup a Github SSH key-pair

You will need to create a new public/private SSH key-pair in order to work with (i.e., pull from/push to) private git repositories (e.g., Github, Gitlab, Azure Devops).

Here's how to set up such a key-pair for named repo providers:

* [Github](https://docs.github.com/en/developers/overview/managing-deploy-keys)
* [Gitlab](https://docs.gitlab.com/ee/user/project/deploy_keys/)
* [Azure Devops](https://docs.microsoft.com/en-us/azure/devops/repos/git/use-ssh-keys-to-authenticate?view=azure-devops)

> We're interested mainly in setting up a key-pair for your Github repo hosting this project.

You'll want to set environment variables starting with `GIT_SSH` - use the [gh-secrets-setup.sh](../scripts/gh-set-secrets.sh) with the `--include-git-ssh-private-key` option to store these values in Github secrets.

Also see [Git Authentication](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.4/tap/GUID-scc-git-auth.html).

### Setup a Personal Access Token in Github

A PAT is required so that workflows can add secrets to the repository in order to be used in downstream jobs.  Documentation can be found [here](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token).

> We are using this personal access token to create secrets for the `oracle` backend for Terraform

### Configure Github Secrets

Setup some Github secrets with the SP credentials.  Documentation can be found [here](https://docs.github.com/en/actions/security-guides/encrypted-secrets).  You might also consider using [gh secret set](https://cli.github.com/manual/gh_secret_set) command to set these individually.

```bash
# This is a personal access token that was created in an above step that allows for the workflows to write secrets
export PA_TOKEN= 
# A valid Oracle region
export ORACLE_REGION= 
# The tenancy identifier for an Oracle Cloud account
export ORACLE_TENANCY_ID= 
# The user identifier for an Oracle Cloud account
export ORACLE_USER_ID= 
# Fingerprint, typically found in $HOME/.oci/config
export ORACLE_FINGERPRINT= 
# Base64-encoded key file contents, e.g., $(cat $HOME/.oci/oci_api_key.pem | base64 -w 0)
export ORACLE_KEY_FILE_CONTENTS= 
# A pre-existing Oracle Cloud compartment identifier#
export ORACLE_COMPARTMENT_ID= 
```


### Create KMS Key

Under Github Actions, manually trigger [oracle-dispatch-key-management-service](../../../actions/workflows/oracle-kms-dispatch.yml).

### Create Remote Backend Support

Under Github Actions, manually trigger [oracle-dispatch-remote-backend-for-terraform-state](../../../actions/workflows/oracle-provided-remote-backend-dispatch.yml).

### Create Toolset Image

Under Github Actions, manually trigger [oracle-build-toolset-image](../../../actions/workflows/oracle-ubuntu-20_04.yml).

Alternatively, you could create the image by executing the oci CLI and Packer script by following these guides:

* [Build](../packer/oracle/ubuntu/20_04/BUILD.md)
* [Test](../packer/oracle/ubuntu/20_04/TEST.md)


## How do I use this?

### Fast path

Take this path when you want to get up-and-running as quickly as possible with the least amount of fuss.

Under Github Actions, manually trigger [oracle-create-workshop-environment](../../../actions/workflows/oracle-e2e.yml)

* The DNS Zone name must be a domain you control and can configure nameservers for


### Slow path

Administer resources one at a time.  Take this path when you want to take a closer look at the GitHub Actions and Terraform modules.

There are two types of actions defined, those that can be manually triggered (i.e., dispatched), and those that can only be called by another action.  All actions are located [here](../../../actions) and can be run by providing the required parameters.  Go [here](../.github/workflows) to inspect the source for each action.

> Note that for most dispatch actions, you have the option to either create or destroy the resources.

#### Modules

| Module       | Github Action       | Terraform               |
| :---       | :---:               | :---:                   |
| KMS |[:x:](../../../actions/workflows/oracle-kms-dispatch.yml) | [:x:](../terraform/oracle/kms) |
| Remote backend | [:x:](../../../actions/workflows/oracle-provided-remote-backend-dispatch.yml) | [:x:](../terraform/oracle/tfstate-support) |
| VPC | [:x:](../../../actions/workflows/oracle-virtual-network-dispatch.yml) | [:white_check_mark:](../terraform/oracle/virtual-network) |
| DNS Zone for base domain | [:x:](../../../actions/workflows/oracle-main-dns-dispatch.yml) | [:white_check_mark:](../terraform/oracle/main-dns) |
| DNS Zone for sub domain | [:x:](../../../actions/workflows/oracle-child-dns-dispatch.yml) | [:white_check_mark:](../terraform/oracle/child-dns) |
| OKE Cluster | [:x:](../../../actions/workflows/oracle-k8s-cluster-dispatch.yml) | [:white_check_mark:](../terraform/oracle/cluster) |
| Container registry | [:x:](../../../actions/workflows/oracle-container-registry-dispatch.yml) | [:white_check_mark:](../terraform/oracle/registry) |
| Harbor | [:x:](../../../actions/workflows/oracle-harbor-dispatch.yml) | [:white_check_mark:](../terraform/k8s/harbor) |
| Bastion | [:x:](../../../actions/workflows/oracle-bastion-dispatch.yml) | [:white_check_mark:](../terraform/oracle/bastion) |
| Secrets Manager | [:x:](../../../actions/workflows/oracle-secrets-manager-dispatch.yml) | [:x:](../terraform/oracle/secrets-manager) |
| Secrets | [:x:](../../../actions/workflows/oracle-secrets-manager-secrets-dispatch.yml) | [:x:](../terraform/oracle/secrets-manager-secrets) |


## Vending credentials

All Credentials are stored in Oracle Cloud Secrets Manager.

First, configure Oracle Cloud using the service account credentials you created earlier

Go visit the Secret Manager Secrets Terraform module's [README](./../terraform/oracle/secrets-manager-secrets/README.md#accessing-a-secret) for how to retrieve secrets.


## Cleaning up everything

In order to destroy all of the resources created you can use the Github action [oracle-destroy-workshop-environment](../../../actions/workflows/oracle-e2e-destroy.yml).  This action should be run with the same inputs used to create an environment.

You'll want also want to `destroy` the remote backend support and KMS key by executing the following jobs:

* [oracle-dispatch-remote-backend-for-terraform-state](../../../actions/workflows/oracle-provided-remote-backend-dispatch.yml)
* [oracle-dispatch-key-management-service](../../../actions/workflows/oracle-kms-dispatch.yml)

> Don't forget to choose `destroy` before clicking on the `Run workflow` button.
