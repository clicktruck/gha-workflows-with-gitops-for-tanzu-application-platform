# Google Cloud Provisioning Automation for Tanzu Application Platform

## Table of Contents

* [Benefits](#benefits)
* [What does it do?](#what-does-it-do)
* [Prerequisites](#prerequisites)
  * [Fork this repository](#fork-this-repository)
  * [Increase Google Cloud Quotas](#increase-google-cloud-quotas)
  * [Setup an Google Cloud service principal](#setup-an-google-cloud-service-principal)
  * [Enable the Secret Manager API](#enable-the-secret-manager-api)
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

This repository provides provisioning automation targeting [Google Cloud](https://cloud.google.com/).


## What does it do?

It provisions the minimum set of cloud resources needed to begin installing Tanzu Application Platform on Google Cloud.


## Prerequisites

### Fork this repository

You will want to fork this GitHub repository and enable the GitHub Actions it contains.

### Increase Google Cloud Quotas

There are a few Google Cloud default [quotas](https://cloud.google.com/compute/quotas) that may need to be adjusted.

1. VM instances
2. Networks

Choose the region and set the limit to >= 30 in your request.

> Note:  The above quotas will be enough to deploy the infrastructure needed for installing TAP.  Individual mileage may vary depending on existing resources.

### Setup an Google Cloud service principal

First, authenticate to Google Cloud.

> Do this only if you are planning on running Terraform scripts locally with an IAM user

```
gcloud auth login
```

Or set the necessary environment variables.

```
export GOOGLE_APPLICATION_CREDENTIALS=<path_to_your_principal_account_key>
```

Then visit the following Terraform module found [here](./../terraform/google/iam) and follow the instructions in the [README](./../terraform/google/iam/README.md)

This will create the service account (with appropriate roles) that will be used by all other Terraform modules.

### Enable the Secret Manager API

Follow these [instructions](https://cloud.google.com/secret-manager/docs/accessing-the-api).


### Setup a Github SSH key-pair

You will need to create a new public/private SSH key-pair in order to work with (i.e., pull from/push to) private git repositories (e.g., Github, Gitlab, Azure Devops).

Here's how to set up such a key-pair for named repo providers:

* [Github](https://docs.github.com/en/developers/overview/managing-deploy-keys)
* [Gitlab](https://docs.gitlab.com/ee/user/project/deploy_keys/)
* [Azure Devops](https://docs.microsoft.com/en-us/azure/devops/repos/git/use-ssh-keys-to-authenticate?view=azure-devops)

> We're interested mainly in setting up a key-pair for your Github repo hosting this project.



Also see [Git Authentication](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.5/tap/scc-git-auth.html).

### Setup a Personal Access Token in Github

A PAT is required so that workflows can add secrets to the repository in order to be used in downstream jobs.  Documentation can be found [here](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token).

> We are using this personal access token to create secrets for the `google` backend for Terraform

### Configure Github Secrets

Setup some Github secrets with the SP credentials.  Documentation can be found [here](https://docs.github.com/en/actions/security-guides/encrypted-secrets).  You might also consider using [gh secret set](https://cli.github.com/manual/gh_secret_set) command to set these individually. Or, after exporting all environment variables below, execute [gh-secrets-setup.sh](../scripts/gh-set-secrets.sh) at the command-line passing `google` as an execution argument.

```bash
# This is a personal access token that was created in an above step that allows for the workflows to write secrets
export PA_TOKEN= 
# The Google Cloud project that will host all resources created
export GOOGLE_PROJECT_ID= 
# The base64-encoded contents of the Google Cloud project's service account key that has the authority to create cloud resources
export GOOGLE_SERVICE_ACCOUNT_KEY= 
```


### Create KMS Key

Under Github Actions, manually trigger [google-dispatch-key-management-service](../../../actions/workflows/google-kms-dispatch.yml).

### Create Remote Backend Support

Under Github Actions, manually trigger [google-dispatch-remote-backend-for-terraform-state](../../../actions/workflows/google-provided-remote-backend-dispatch.yml).

### Create Toolset Image

Under Github Actions, manually trigger [google-build-toolset-image](../../../actions/workflows/google-ubuntu-22_04.yml).

Alternatively, you could create the AMI by executing the aws CLI and Packer script by following these guides:

* [Build](../packer/google/ubuntu/22_04/BUILD.md)
* [Test](../packer/google/ubuntu/22_04/TEST.md)


## How do I use this?

### Fast path

Take this path when you want to get up-and-running as quickly as possible with the least amount of fuss.

Under Github Actions, manually trigger one of:

* [google-create-autopilot-workshop-environment](../../../actions/workflows/google-autopilot-e2e.yml)
  > **Warning** This is a sentry workflow.  It fails to complete provisioning all resources.
* [google-create-workshop-environment](../../../actions/workflows/google-e2e.yml)

> The DNS Zone name must be a domain you control and can configure nameservers for


### Slow path

Administer resources one at a time.  Take this path when you want to take a closer look at the GitHub Actions and Terraform modules.

There are two types of actions defined, those that can be manually triggered (i.e., dispatched), and those that can only be called by another action.  All actions are located [here](../../../actions) and can be run by providing the required parameters.  Go [here](../.github/workflows) to inspect the source for each action.

> Note that for most dispatch actions, you have the option to either create or destroy the resources.

#### Modules

| Module       | Github Action       | Terraform               |
| :---       | :---:               | :---:                   |
| KMS |[:white_check_mark:](../../../actions/workflows/google-kms-dispatch.yml) | [:white_check_mark:](../terraform/google/kms) |
| Remote backend | [:white_check_mark:](../../../actions/workflows/google-provided-remote-backend-dispatch.yml) | [:white_check_mark:](../terraform/google/tfstate-support) |
| VPC | [:white_check_mark:](../../../actions/workflows/google-virtual-network-dispatch.yml) | [:white_check_mark:](../terraform/google/virtual-network) |
| DNS Zone for base domain | [:white_check_mark:](../../../actions/workflows/google-main-dns-dispatch.yml) | [:white_check_mark:](../terraform/google/main-dns) |
| DNS Zone for sub domain | [:white_check_mark:](../../../actions/workflows/google-child-dns-dispatch.yml) | [:white_check_mark:](../terraform/google/child-dns) |
| GKE Cluster | [:white_check_mark:](../../../actions/workflows/google-k8s-cluster-dispatch.yml) | [:white_check_mark:](../terraform/google/cluster/standard) |
| GKE Autopilot Cluster | [:white_check_mark:](../../../actions/workflows/google-k8s-autopilot-cluster-dispatch.yml) | [:white_check_mark:](../terraform/google/cluster/autopilot) |
| Container registry | [:white_check_mark:](../../../actions/workflows/google-container-registry-dispatch.yml) | [:white_check_mark:](../terraform/google/registry) |
| Harbor | [:white_check_mark:](../../../actions/workflows/google-harbor-dispatch.yml) | [:white_check_mark:](../terraform/k8s/harbor) |
| Bastion | [:white_check_mark:](../../../actions/workflows/google-bastion-dispatch.yml) | [:white_check_mark:](../terraform/google/bastion) |
| Secrets Manager | [:white_check_mark:](../../../actions/workflows/google-secrets-manager-dispatch.yml) | [:white_check_mark:](../terraform/google/secrets-manager) |
| Secrets | [:white_check_mark:](../../../actions/workflows/google-secrets-manager-secrets-dispatch.yml) | [:white_check_mark:](../terraform/google/secrets-manager-secrets) |


## Vending credentials

All Credentials are stored in Google Cloud Secrets Manager.

First, configure Google Cloud using the service account credentials you created earlier

Go visit the Secret Manager Secrets Terraform module's [README](./../terraform/google/secrets-manager-secrets/README.md#accessing-a-secret) for how to retrieve secrets.


## Cleaning up everything

In order to destroy all of the resources created you can use the Github action [google-destroy-workshop-environment](../../../actions/workflows/google-e2e-destroy.yml).  This action should be run with the same inputs used to create an environment.

You'll want also want to `destroy` the remote backend support and KMS key by executing the following jobs:

* [google-dispatch-remote-backend-for-terraform-state](../../../actions/workflows/google-provided-remote-backend-dispatch.yml)
* [google-dispatch-key-management-service](../../../actions/workflows/google-kms-dispatch.yml)

> Don't forget to choose `destroy` before clicking on the `Run workflow` button.
