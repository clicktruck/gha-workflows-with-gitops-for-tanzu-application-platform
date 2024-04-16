# Sample Github CLI Dispatch Workflows targeting Amazon Web Services

Credentials or sensitive configuration shared in the examples below are for illustrative purposes only.

See [gh workflow run](https://cli.github.com/manual/gh_workflow_run) for additional options.

## Table of contents

* [Create fork of this repo](#create-fork-of-this-repo)
* [Create Toolset Image on AWS](#create-toolset-image-on-aws)
* [Provision AWS Route53 Hosted Zones](#provision-aws-route53-hosted-zones)
  * [Create KMS key and alias](#create-kms-key-and-alias)
  * [Create S3 bucket and DynamoDB table for backend Terraform state management](#create-s3-bucket-and-dynamodb-table-for-backend-terraform-state-management)
  * [Create hosted zone for base domain](#create-hosted-zone-for-base-domain)
  * [Create hosted zone for child domain](#create-hosted-zone-for-child-domain)
* [Provision EKS and ECR on AWS](#provision-eks-and-ecr-on-aws)
  * [Create KMS key and alias](#create-kms-key-and-alias-1)
  * [Create S3 bucket and DynamoDB table for backend Terraform state management](#create-s3-bucket-and-dynamodb-table-for-backend-terraform-state-management-1)
  * [Provision keypair, cluster, registry, secrets manager, and secrets](#provision-keypair-cluster-registry-secrets-manager-and-secrets)
* [Provision Tanzu Kubernetes Grid clusters and Harbor on AWS](#provision-tanzu-kubernetes-grid-clusters-and-harbor-on-aws)
  * [One-time setup w/ Tanzu CloudFormation Stack](#one-time-setup-w-tanzu-cloudformation-stack)
  * [Create KMS key and alias](#create-kms-key-and-alias-2)
  * [Create S3 bucket and DynamoDB table for backend Terraform state management](#create-s3-bucket-and-dynamodb-table-for-backend-terraform-state-management-2)
  * [Provision keypair, management cluster, workload clusters, secrets manager, and secrets](#provision-keypair-management-cluster-workload-clusters-secrets-manager-and-secrets)
* [Relocate TAP images from Tanzu Network](#relocate-tap-images-from-tanzu-network)
* [Install Tanzu Application Platform targeting TKG on AWS or EKS](#install-tanzu-application-platform-targeting-tkg-on-aws-or-eks)
  * [Install prereqs into cluster](#install-prereqs-into-cluster)
  * [Install](#install)


## Create fork of this repo

<details>
<summary>Show</summary>
<p>

```bash
gh repo fork clicktruck/gha-workflows-with-gitops-for-tanzu-application-platform
```

</p>
</details>

## Create toolset image on AWS

<details>
<summary>Show</summary>
<p>

```bash
echo '{ "instance-type": "t3a.xlarge", "region": "us-west-2" }' | gh workflow run aws-ubuntu-22_04.yml --json
```

</p>
</details>


## Provision AWS Route53 Hosted Zones

_You are strongly encouraged to setup a personal AWS account for managing personal domains_.

We'll assume hosted zones are managed in a separate AWS account.  (It's usually the case in enterprises where a separation of OpSec roles/duties are enforced).

### Create KMS key and alias

<details>
<summary>Show</summary>
<p>

```bash
echo '{ "aws-access-key-id": "ASIA5K3T6JXVBF2LFS5B", "aws-secret-access-key": "Zqyo0LM4i9NCzrD6VgoHrAS7B6u6N4HuRRY/nswy", "alias":"hzm", "region": "us-west-2", "action": "create" }' | gh workflow run aws-kms-dispatch.yml --json
```

</p>
</details>


### Create S3 bucket and DynamoDB table for backend Terraform state management

<details>
<summary>Show</summary>
<p>

```bash
echo '{ "aws-access-key-id": "ASIA5K3T6JXVBF2LFS5B", "aws-secret-access-key": "Zqyo0LM4i9NCzrD6VgoHrAS7B6u6N4HuRRY/nswy", "s3-bucket-name": "hzm", "region": "us-west-2", "action": "create" }' | gh workflow run aws-provided-remote-backend-dispatch.yml --json
```

</p>
</details>


### Create hosted zone for base domain

<details>
<summary>Show</summary>
<p>

```bash
echo '{ "aws-access-key-id": "ASIA5K3T6JXVBF2LFS5B", "aws-secret-access-key": "Zqyo0LM4i9NCzrD6VgoHrAS7B6u6N4HuRRY/nswy", "domain": "zoolabs.me", "region": "us-west-2", "action": "create" }' | gh workflow run aws-main-dns-dispatch.yml --json
```

</p>
</details>

> Note: your domain registrar may or may not be your cloud provider.  If not, you will need to update nameserver entries for your domain using the NS record from the Route53 hosted zone in your domain registrar.

### Create hosted zone for child domain

<details>
<summary>Show</summary>
<p>

```bash
echo '{ "aws-access-key-id": "ASIA5K3T6JXVBF2LFS5B", "aws-secret-access-key": "Zqyo0LM4i9NCzrD6VgoHrAS7B6u6N4HuRRY/nswy", "baseDomain": "zoolabs.me", "domainPrefix": "apps", "region": "us-west-2", "action": "create" }' | gh workflow run aws-child-dns-dispatch.yml --json
```

</p>
</details>


After provisioning hosted zones above, [create IAM account credentials](../creating-an-iam-user-account-with-route53-hosted-zone-management-privileges/README.md) for each.

> Remember these for later steps.


## Provision EKS and ECR on AWS

### Create KMS key and alias

<details>
<summary>Show</summary>
<p>

```bash
echo '{ "aws-access-key-id": "ASIA5K3T6JXVCZR54SP7", "aws-secret-access-key": "2dz2M6Y3SBkiYYc2jlXTQMGoRN6absmlBFiPFuO5", "aws-session-token": "IQoJb3JpZ2luX2VjEPP//////////wEaCX...", "alias": "tap", "region": "us-west-2", "action": "create" }' | gh workflow run aws-kms-dispatch.yml --json
```
> In this particular example the `aws-access-key-id`, `aws-secret-access-key`, and `aws-session-token` may be the same as the ones you had provided as Github secrets if you're working with expiring credentials from STS.

</p>
</details>


### Create S3 bucket and DynamoDB table for backend Terraform state management

<details>
<summary>Show</summary>
<p>

```bash
echo '{ "aws-access-key-id": "ASIA5K3T6JXVCZR54SP7", "aws-secret-access-key": "2dz2M6Y3SBkiYYc2jlXTQMGoRN6absmlBFiPFuO5", "aws-session-token": "IQoJb3JpZ2luX2VjEPP//////////wEaCX...", "s3-bucket-name": "tap", "region": "us-west-2", "action": "create" }' | gh workflow run aws-provided-remote-backend-dispatch.yml --json
```
> In this particular example the `aws-access-key-id`, `aws-secret-access-key`, and `aws-session-token` may be the same as the ones you had provided as Github secrets if you're working with expiring credentials from STS.

</p>
</details>


### Provision keypair, cluster, registry, secrets manager, and secrets

<details>
<summary>Show</summary>
<p>

```bash
echo '{ "vpc-cidr": "10.60.0.0/18", "footprint": "single-cluster", "aws-access-key-id": "ASIA5K3T6JXVCZR54SP7", "aws-secret-access-key": "2dz2M6Y3SBkiYYc2jlXTQMGoRN6absmlBFiPFuO5", "aws-session-token": "IQoJb3JpZ2luX2VjEPP//////////wEaCX...", "region": "us-west-2", "instance-type": "m5a.xlarge", "email-address": "admin@zoolabs.me", "domain": "zoolabs.me", "container-image-registry-provider": "harbor" }' | gh workflow run aws-e2e.yml --json
```
> You can also provision w/ `"footprint": "multi-cluster"` too.

</p>
</details>


## Provision Tanzu Kubernetes Grid clusters and Harbor on AWS

### One-time setup w/ Tanzu CloudFormation Stack

<details>
<summary>Show</summary>
<p>

```bash
echo '{ "region": "us-west-2", "action": "create" }' | gh workflow run aws-tanzu-cloudformation-stack-dispatch.yml --json
```

</p>
</details>


### Create KMS key and alias

<details>
<summary>Show</summary>
<p>

```bash
echo '{ "aws-access-key-id": "ASIA5K3T6JXVCZR54SP7", "aws-secret-access-key": "2dz2M6Y3SBkiYYc2jlXTQMGoRN6absmlBFiPFuO5", "aws-session-token": "IQoJb3JpZ2luX2VjEPP//////////wEaCX...", "alias": "tap", "region": "us-west-2", "action": "create" }' | gh workflow run aws-kms-dispatch.yml --json
```
> In this particular example the `aws-access-key-id`, `aws-secret-access-key`, and `aws-session-token` may be the same as the ones you had provided as Github secrets if you're working with expiring credentials from STS.

</p>
</details>


### Create S3 bucket and DynamoDB table for backend Terraform state management

<details>
<summary>Show</summary>
<p>

```bash
echo '{ "aws-access-key-id": "ASIA5K3T6JXVCZR54SP7", "aws-secret-access-key": "2dz2M6Y3SBkiYYc2jlXTQMGoRN6absmlBFiPFuO5", "aws-session-token": "IQoJb3JpZ2luX2VjEPP//////////wEaCX...", "s3-bucket-name": "tap", "region": "us-west-2", "action": "create" }' | gh workflow run aws-provided-remote-backend-dispatch.yml --json
```
> In this particular example the `aws-access-key-id`, `aws-secret-access-key`, and `aws-session-token` may be the same as the ones you had provided as Github secrets if you're working with expiring credentials from STS.

</p>
</details>


### Provision keypair, management cluster, workload clusters, secrets manager, and secrets

<details>
<summary>Show</summary>
<p>

```bash
echo '{ "footprint": "single-cluster", "aws-access-key-id": "ASIA5K3T6JXVHHFQOKGR", "aws-secret-access-key": "ufVqiTP/JnETOl/wYPVJU7ovlbOsrnysX9YG351M", "region": "us-west-2", "availability-zones": "us-west-2a,us-west-2b,us-west-2c", "email-address": "admin@zoolabs.me", "domain": "zoolabs.me", "control-plane-node-machine-type": "m5a.large", "worker-node-machine-type": "m5a.xlarge" }' | gh workflow run tkg-on-aws-e2e.yml --json
```
> In the above example `aws-access-key-id` and `aws-secret-access-key` are the credentials for managing a Route53 hosted zone (i.e., for base domain).  You can also provision w/ `"footprint": "multi-cluster"` too.

</p>
</details>


### Add new project to Harbor

<details>
<summary>Show</summary>
<p>

```bash
echo '{ "username": "admin", "password": "flipp3r", "api-endpoint": "harbor.zoolabs.me", "project": "tanzu" }' | gh workflow run create-harbor-project-dispatch.yml --json
```
> In the above example, if `project` is set to a value other than `tanzu`, then you'll need to review and edit the configuration values under `tap.registry.repositories` in [tap-value-input.yml](../../../gitops/tanzu/application-platform/base/tap-values-input.yml).

</p>
</details>


## Install Tanzu Application Platform targeting TKG on AWS or EKS

Steps below assume you have a _target cluster_, a _container image registry_, and a _Route53_ hosted zone setup.  If you ran a provisioning workflow above, you may [find](https://docs.aws.amazon.com/secretsmanager/latest/userguide/manage_search-secret.html) sensitive configuration in a [Secrets Manager](https://docs.aws.amazon.com/secretsmanager/latest/userguide/intro.html) instance.

If you have an account with console access you could visit [https://{aws-region}.console.aws.amazon.com/secretsmanager/home?region={aws-region}#!/listSecrets/](https://{aws-region}.console.aws.amazon.com/secretsmanager/home?region={aws-region}#!/listSecrets/).  Replace occurrences of `{aws-region}` in that URL with a valid AWS region.


### Fetch AWS Route53 hosted zone identifier for domain

<details>
<summary>Show</summary>
<p>

```bash
echo '{ "aws-access-key-id": "ASIA5K3T6JXVI4EL3HSD", "aws-secret-access-key": "7dpB+TuTJKxfQCJkKFcY8DM+DvRkMWF67mE7Vqfp", "domain": "apps.zoolabs.me", "region": "us-west-2" }' | gh workflow run aws-get-route53-hosted-zone-id-for-domain-dispatch.yml --json
```
> In the above example `aws-access-key-id` and `aws-secret-access-key` are the credentials for managing a Route53 hosted zone (i.e., for child domain).  You will need to review the job logs to see what the hosted zone identifier is.  Or if you're impatient and you have administrator credentials for the account managing the hosted zone and/or credentials with console access, you can visit https://us-east-1.console.aws.amazon.com/route53/v2/hostedzones#.  You will need this value for the next step!

</p>
</details>


## Install prereqs into cluster

<details>
<summary>Show</summary>
<p>

```bash
echo '{ "cluster-provider": "eks", "kubeconfig-contents": "KVkfThQJXekP3fIgzasYb3lD..." }' | gh workflow run install-tanzu-cluster-essentials-dispatch.yml --json
```
> Only executed on Non-TKG clusters.  This is actually automatically installed if you executed [ aws-k8s-cluster-dispatch, azure-k8s-cluster-dispatch, google-k8s-cluster-dispatch ] workflows.

```bash
echo '{ "tkg-version": "v2023.9.19", "cluster-provider": "eks", "kubeconfig-contents": "KVkfThQJXekP3fIgzasYb3lD..." }' | gh workflow run install-tanzu-standard-repo-dispatch.yml --json
```
> Only executed on Non-TKG clusters.  This is actually automatically installed if you executed [ aws-k8s-cluster-dispatch, azure-k8s-cluster-dispatch, google-k8s-cluster-dispatch ] workflows.

```bash
echo '{ "domain": "zoolabs.me", "email-address": "admin@zoolabs.me", "aws-access-key-id": "ASIA5K3T6JXVBF2LFS5B", "aws-secret-access-key": "Zqyo0LM4i9NCzrD6VgoHrAS7B6u6N4HuRRY/nswy", "aws-region": "us-west-2", "cluster-provider": "eks", "kubeconfig-contents": "KVkfThQJXekP3fIgzasYb3lD..." }' | gh workflow run install-tanzu-ingress-dispatch.yml --json
```
> Execute this command for clusters configured to host `view` or `full` Tanzu Application Platform profiles.  Provides Contour ingress including a Let's Encrypt ClusterIssuer and External-DNS configuration.  The sample AWS credentials above are for the user account with write permissions to a Route53 hosted zone.  Note, this dispatch workflow supports variant configuration for targeting Azure AKS and Google GKE clusters.  To-date only the following `cluster-provider`s are supported: [ "aks", "eks", "gke", "tkg»aws", "tkg»azure" ].

</p>
</details>

### Relocate TAP images from Tanzu Network

Do this once

```bash
echo '{ "container-image-registry-url": "harbor.zoolabs.me", "container-image-registry-username": "admin", "container-image-registry-password": "cEBzc3cwcmQlCg==", "container-image-registry-provider": "harbor-on-aws"}' | gh workflow relocate-tap-images-from-tanzu-network-to-container-registry-dispatch.yml --json
```

### Install

Single-cluster

<details>
<summary>Show</summary>
<p>

```bash
echo '{ "tap-install-details": "apps.zoolabs.me;admin@zoolabs.me";default";https://github.com/clicktruck/tap-gui-catalog/blob/main/catalog-info.yaml", "container-image-registry-provider": "harbor-on-aws", container-image-registry-connection-details": "harbor.zoolabs.me;admin;cEBzc3cwcmQlCg==;tap-build-service;tanzu-application-platform;arn-replace-me;arn-replace-me", "cluster-provider": "tkg»aws", "active-profile": "full", "kubeconfig-contents": "dGhpcyBrdWJlY29uZmlnIGlzIGVudGlyZWx5IGZha2UK..." }' | gh workflow run install-tanzu-application-platform-dispatch.yml --json
```
> Note, this dispatch workflow supports variant configuration for targeting Amazon EKS, Azure AKS and Google GKE clusters.  To-date only the following `cluster-provider`s are supported: [ "aks", "eks", "gke", "tkg»aws", "tkg»azure" ].  Other optional options may apply depending on choice of provider.


</p>
</details>

Multi-cluster

<details>
<summary>Show</summary>
<p>

```bash
echo '{ "secrets-manager-arn": "arn:aws:xx-xxxxx", "secrets-manager-instance-name": "tap-secret-store", "domain": "apps.ironleg.me", "email-address": "admin@zoolabs.me", "aws-access-key-id": "ASIA5K3T6JXVBF2LFS5B", "aws-secret-access-key": "Zqyo0LM4i9NCzrD6VgoHrAS7B6u6N4HuRRY/nswy", "backstage-catalog": "https://github.com/clicktruck/tap-gui-catalog/blob/main/catalog-info.yaml", "cluster-provider": "tkg»aws", "container-image-registry-provider": "harbor-on-aws", "aws-region": "us-west-2" }' | gh workflow run multi-cluster-tanzu-application-platform-install-on-aws-dispatch.yml --json
```
> In this context, `cluster-provider` can be: [ "eks", "tkg»aws" ], `container-image-registry-provider` can be: [ "elastic-container-registry", "harbor-on-aws" ]

</p>
</details>