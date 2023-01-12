# AWS Provisioning Automation for Tanzu Application Platform

## Table of Contents

* [Benefits](#benefits)
* [What does it do?](#what-does-it-do)
* [Prerequisites](#prerequisites)
  * [Fork this repository](#fork-this-repository)
  * [Increase AWS Quotas](#increase-aws-quotas)
  * [(Optional) Setup an AWS service principal](#optional-setup-an-aws-service-principal)
  * [Setup a Github SSH key-pair](#setup-a-github-ssh-key-pair)
  * [Setup a Personal Access Token in Github](#setup-a-personal-access-token-in-github)
  * [Configure Github Secrets](#configure-github-secrets)
  * [Create KMS Key](#create-kms-key)
  * [Create Remote Backend Support](#create-remote-backend-support)
  * [Create Toolset AMI](#create-toolset-ami)
* [How do I use this?](#how-do-i-use-this)
  * [Fast path](#fast-path)
  * [Slow path](#slow-path)
    * [Modules](#modules)
* [Vending credentials](#vending-credentials)
* [Cleaning up everything](#cleaning-up-everything)


## Benefits

This repository provides provisioning automation targeting [AWS](https://aws.amazon.com/).


## What does it do?

It provisions the minimum set of cloud resources needed to begin installing Tanzu Application Platform on AWS.


## Prerequisites

### Fork this repository

You will want to fork this GitHub repository and enable the GitHub Actions it contains.

### Increase AWS Quotas

There are a few AWS default quotas that will need to be adjusted.

1. EC2 instance quota - In the AWS portal, visit the Support Center and [create a case](https://console.aws.amazon.com/support/home?#/case/create?issueType=service-limit-increase&limitType=service-code-ec2-instances). Choose the region, primary instance type, and set the limit to >= 25 in your request.
2. Elastic IP Addresses - In the AWS portal, visit the Support Center and [create a case](https://console.aws.amazon.com/support/home?#/case/create?issueType=service-limit-increase&limitType=service-code-elastic-ips). Choose the region and set the limit to >= 30 in your request.

> Note:  The above quotas will be enough to deploy the infrastructure needed for installing TAP.  Individual mileage may vary depending on existing resources.

### (Optional) Setup an AWS service principal

First, configure AWS authentication.

> Do this only if you are planning on running Terraform scripts locally with an IAM user (i.e., you're not using AWS Session Token Service).

```bash
aws configure
```

Or set the necessary environment variables.

```bash
export AWS_ACCESS_KEY_ID=<your_root_access_key_id>
export AWS_SECRET_ACCESS_KEY=<your_root_secret_access_key>
export AWS_REGION=<region_cloud_resources_will_be_provisioned_and_accessed>
```

Next, set the following environment variables for your service account.

```bash
export AWS_SERVICE_ACCOUNT_NAME=<your_service_account_name>
export AWS_SERVICE_ACCOUNT_PASSWORD=<your_service_account_password>
```

Then, run the following script found [here](../scripts/aws/create-aws-service-account.sh).

```bash
./scripts/aws/create-aws-service-account.sh
```
> Record the `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` of the new service account.  These are the credentials you should use going forward with Terraform modules.

### Setup a Github SSH key-pair

You will need to create a new public/private SSH key-pair in order to work with (i.e., pull from/push to) private git repositories (e.g., Github, Gitlab, Azure Devops).

Here's how to set up such a key-pair for named repo providers:

* [Github](https://docs.github.com/en/developers/overview/managing-deploy-keys)
* [Gitlab](https://docs.gitlab.com/ee/user/project/deploy_keys/)
* [Azure Devops](https://docs.microsoft.com/en-us/azure/devops/repos/git/use-ssh-keys-to-authenticate?view=azure-devops)

> We're interested mainly in setting up a key-pair for your Github repo hosting this project.

You'll want to set environment variables starting with `GIT_SSH` - use the [gh-secrets-setup.sh](../scripts/gh-set-secrets.sh) with the `--include-git-ssh-private-key` option to store these values in Github secrets.

Also see [Git Authentication](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.4/tap/scc-git-auth.html).

### Setup a Personal Access Token in Github

A PAT is required so that workflows can add secrets to the repository in order to be used in downstream jobs.  Documentation can be found [here](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token).

> We are using this personal access token to create secrets for the `aws` backend for Terraform

### Configure Github Secrets

Setup some Github secrets with the SP credentials.  Documentation can be found [here](https://docs.github.com/en/actions/security-guides/encrypted-secrets).  You might also consider using [gh secret set](https://cli.github.com/manual/gh_secret_set) command to set these individually.

```bash
# This is a personal access token that was created in an above step that allows for the workflows to write secrets
export PA_TOKEN= 
# The access key identifier associated with role-based temporary security credentials vended from AWS Security Token Service
export AWS_ACCESS_KEY_ID= 
# The access key's secret associated with role-based temporary security credentials vended from AWS Security Token Service
export AWS_SECRET_ACCESS_KEY= 
# An expiring session token associated with role-based temporary security credentials vended from AWS Security Token Service
export AWS_SESSION_TOKEN= 
```
> Setting up a `AWS_SESSION_TOKEN` secret is optional.  However, if you have to obtain an AWS Session Token Service token (via a provider like [CloudGate](https://console.cloudgate.vmware.com/ui/#/login)) in order to authenticate to an AWS account, you will need to periodically update the `AWS_*` secret values as the token is typically set to expire.


### Create KMS Key

Under Github Actions, manually trigger [aws-01-dispatch-key-management-service](../../../actions/workflows/aws-kms-dispatch.yml).

### Create Remote Backend Support

Under Github Actions, manually trigger [aws-02-dispatch-remote-backend-for-terraform-state](../../../actions/workflows/aws-provided-remote-backend-dispatch.yml).

### Create Toolset AMI

Under Github Actions, manually trigger [aws-04-build-toolset-image](../../../actions/workflows/aws-ubuntu-22_04.yml).

If the job completes successfully, you will need to look up the `Owner account ID`.

You could do that by visiting the following URL in your favorite browser

```
https://{AWS_REGION}.console.aws.amazon.com/ec2/v2/home?region={AWS_REGION}#Images:
```
> Replace occurrences of `{AWS_REGION}` above with the value you configured earlier as a Github Secret employed by the Github Action.  You will see a listing of all AMIs that you have permissions to view.  Look for an AMI starting with the name you defined in the job inputs.  Click on the AMI id hyerlink, then record the Owner account ID as you will need it in later steps.

Alternatively, you could create the AMI by executing the aws CLI and Packer script by following these guides:

* [Build](../packer/aws/ubuntu/22_04/BUILD.md)
* [Test](../packer/aws/ubuntu/22_04/TEST.md)


## How do I use this?

### Fast path

Take this path when you want to get up-and-running as quickly as possible with the least amount of fuss.

Under Github Actions, manually trigger [aws-create-workshop-environment](../../../actions/workflows/aws-e2e.yml)

* The DNS Zone name must be a domain you control and can configure nameservers for
* Instance types can be found [here](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/general-purpose-instances.html#general-purpose-hardware) - `m5a.large` is a good option


### Slow path

Administer resources one at a time.  Take this path when you want to take a closer look at the GitHub Actions and Terraform modules.

There are two types of actions defined, those that can be manually triggered (i.e., dispatched), and those that can only be called by another action.  All actions are located [here](../../../actions) and can be run by providing the required parameters.  Go [here](../.github/workflows) to inspect the source for each action.

> Note that for most dispatch actions, you have the option to either create or destroy the resources.

#### Modules

| Module       | Github Action       | Terraform               |
| :---       | :---:               | :---:                   |
| KMS |[:white_check_mark:](../../../actions/workflows/aws-kms-dispatch.yml) | [:white_check_mark:](../terraform/aws/kms) |
| Remote backend | [:white_check_mark:](../../../actions/workflows/aws-provided-remote-backend-dispatch.yml) | [:white_check_mark:](../terraform/aws/tfstate-support) |
| Keypair | [:white_check_mark:](../../../actions/workflows/aws-keypair-dispatch.yml) | [:white_check_mark:](../terraform/azure/keypair) |
| VPC | [:white_check_mark:](../../../actions/workflows/aws-virtual-network-dispatch.yml) | [:white_check_mark:](../terraform/aws/virtual-network) |
| DNS Zone for base domain | [:white_check_mark:](../../../actions/workflows/aws-main-dns-dispatch.yml) | [:white_check_mark:](../terraform/aws/main-dns) |
| DNS Zone for sub domain | [:white_check_mark:](../../../actions/workflows/aws-child-dns-dispatch.yml) | [:white_check_mark:](../terraform/aws/child-dns) |
| EKS Cluster | [:white_check_mark:](../../../actions/workflows/aws-k8s-cluster-dispatch.yml) | [:white_check_mark:](../terraform/aws/cluster) |
| EKS Cluster Addons | [:x:] | [:white_check_mark:](../terraform/aws/cluster-addons) |
| EKS Cluster Storage Updates | [:x:] | [:white_check_mark:](../terraform/aws/cluster-storage) |
| Container registry | [:white_check_mark:](../../../actions/workflows/aws-container-registry-dispatch.yml) | [:white_check_mark:](../terraform/aws/registry) |
| Harbor | [:white_check_mark:](../../../actions/workflows/aws-harbor-dispatch.yml) | [:white_check_mark:](../terraform/k8s/harbor) |
| Bastion | [:white_check_mark:](../../../actions/workflows/aws-bastion-dispatch.yml) | [:white_check_mark:](../terraform/aws/bastion) |
| Secrets Manager | [:white_check_mark:](../../../actions/workflows/aws-secrets-manager-dispatch.yml) | [:white_check_mark:](../terraform/aws/secrets-manager) |
| Secrets | [:white_check_mark:](../../../actions/workflows/aws-secrets-manager-secrets-dispatch.yml) | [:white_check_mark:](../terraform/aws/secrets-manager-secrets) |


## Vending credentials

All Credentials are stored in AWS Secrets Manager.

There is only one credential that needs to be pulled down to get started, all other credentials will be accessible from the bastion host. This credential is the private SSH key for the bastion host.

First, configure AWS using the service account credentials you created earlier or ask for temporary security credentials from STS.

```bash
aws secretsmanager get-secret-value --secret-id {SECRETS_MANAGER_ARN}
```
> Replace the `{SECRETS_MANAGER_ARN}` with the ARN of the secrets manager instance.  A response in JSON-format will contain all the credentials you need to connect to the bastion host, cluster and container registry.

Refer to [Tutorial: Create and retrieve a secret](https://docs.aws.amazon.com/secretsmanager/latest/userguide/tutorials_basic.html#tutorial-basic-step2) for an example.


## Cleaning up everything

In order to destroy all of the resources created you can use the Github action [aws-destroy-workshop-environment](../../../actions/workflows/aws-e2e-destroy.yml).  This action should be run with the same inputs used to create an environment.

You'll want also want to `destroy` the remote backend support and KMS key by executing the following jobs:

* [aws-02-dispatch-remote-backend-for-terraform-state](../../../actions/workflows/aws-provided-remote-backend-dispatch.yml)
* [aws-01-dispatch-key-management-service](../../../actions/workflows/aws-kms-dispatch.yml)

> Don't forget to choose `destroy` before clicking on the `Run workflow` button.
