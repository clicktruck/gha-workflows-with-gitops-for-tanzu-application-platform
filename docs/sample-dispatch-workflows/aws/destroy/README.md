# Sample Github CLI Dispatch Workflows targeting Amazon Web Services

Credentials or sensitive configuration shared in the examples below are for illustrative purposes only.

See [gh workflow run](https://cli.github.com/manual/gh_workflow_run) for additional options.

## Table of contents

* [Teardown AWS Route53 Hosted Zones](#teardown-aws-route53-hosted-zones)
  * [Destroy KMS key and alias](#destroy-kms-key-and-alias)
  * [Destroy S3 bucket and DynamoDB table for backend Terraform state management](#destroy-s3-bucket-and-dynamodb-table-for-backend-terraform-state-management)
  * [Destroy hosted zone for base domain](#destroy-hosted-zone-for-base-domain)
  * [Destroy hosted zone for child domain](#destroy-hosted-zone-for-child-domain)
* [Teardown EKS and ECR on AWS](#teardown-eks-and-ecr-on-aws)
  * [Destroy KMS key and alias](#destroy-kms-key-and-alias-1)
  * [Destroy S3 bucket and DynamoDB table for backend Terraform state management](#destroy-s3-bucket-and-dynamodb-table-for-backend-terraform-state-management-1)
  * [Teardown keypair, cluster, registry, secrets manager, and secrets](#teardown-keypair-cluster-registry-secrets-manager-and-secrets)
* [Teardown Tanzu Kubernetes Grid clusters and Harbor on AWS](#teardown-tanzu-kubernetes-grid-clusters-and-harbor-on-aws)
  * [Destroy Tanzu CloudFormation Stack](#destroy-tanzu-cloudformation-stack)
  * [Destroy KMS key and alias](#destroy-kms-key-and-alias-2)
  * [Destroy S3 bucket and DynamoDB table for backend Terraform state management](#destroy-s3-bucket-and-dynamodb-table-for-backend-terraform-state-management-2)
  * [Teardown keypair, management cluster, workload clusters, secrets manager, and secrets](#teardown-keypair-management-cluster-workload-clusters-secrets-manager-and-secrets)
* [Uninstall Tanzu Application Platform targeting TKG on AWS or EKS](#uninstall-tanzu-application-platform-targeting-tkg-on-aws-or-eks)
  * [Uninstall](#uninstall)
* [Uninstall prereqs in cluster](#uninstall-prereqs-in-cluster)


## Teardown AWS Route53 Hosted Zones

We'll assume hosted zones are managed in a separate AWS account.  (It's usually the case in enterprises where a separation of OpSec roles/duties are enforced).

### Destroy KMS key and alias

<details>
<summary>Show</summary>
<p>

```bash
echo '{ "aws-access-key-id": "ASIA5K3T6JXVBF2LFS5B", "aws-secret-access-key": "Zqyo0LM4i9NCzrD6VgoHrAS7B6u6N4HuRRY/nswy", "region": "us-west-2", "action": "destroy" }' | gh workflow run aws-kms-dispatch.yml --json
```

</p>
</details>


### Destroy S3 bucket and DynamoDB table for backend Terraform state management

<details>
<summary>Show</summary>
<p>

```bash
echo '{ "aws-access-key-id": "ASIA5K3T6JXVBF2LFS5B", "aws-secret-access-key": "Zqyo0LM4i9NCzrD6VgoHrAS7B6u6N4HuRRY/nswy", "s3-bucket-name": "hosted-zone-management-tfstate-fg78mK", "region": "us-west-2", "action": "destroy" }' | gh workflow run aws-provided-remote-backend-dispatch.yml --json
```

</p>
</details>


### Destroy hosted zone for base domain

<details>
<summary>Show</summary>
<p>

```bash
echo '{ "aws-access-key-id": "ASIA5K3T6JXVBF2LFS5B", "aws-secret-access-key": "Zqyo0LM4i9NCzrD6VgoHrAS7B6u6N4HuRRY/nswy", "domain": "zoolabs.me", "region": "us-west-2", "action": "destroy" }' | gh workflow run aws-main-dns-dispatch.yml --json
```

</p>
</details>

> Note: your domain registrar may or may not be your cloud provider.  If not, you will need to update nameserver entries for your domain using the NS record from the Route53 hosted zone in your domain registrar.

### Destroy hosted zone for child domain

<details>
<summary>Show</summary>
<p>

```bash
echo '{ "aws-access-key-id": "ASIA5K3T6JXVBF2LFS5B", "aws-secret-access-key": "Zqyo0LM4i9NCzrD6VgoHrAS7B6u6N4HuRRY/nswy", "baseDomain": "zoolabs.me", "domainPrefix": "apps", "region": "us-west-2", "action": "destroy" }' | gh workflow run aws-child-dns-dispatch.yml --json
```

</p>
</details>


After destroying the hosted zones above, it is left as a manual exercise to destroy unused IAM accounts, attached policies, and credentials for each.


## Teardown EKS and ECR on AWS

### Destroy KMS key and alias

<details>
<summary>Show</summary>
<p>

```bash
echo '{ "aws-access-key-id": "ASIA5K3T6JXVCZR54SP7", "aws-secret-access-key": "2dz2M6Y3SBkiYYc2jlXTQMGoRN6absmlBFiPFuO5", "aws-session-token": "IQoJb3JpZ2luX2VjEPP//////////wEaCX...", "region": "us-west-2", "action": "destroy" }' | gh workflow run aws-kms-dispatch.yml --json
```
> In this particular example the `aws-access-key-id`, `aws-secret-access-key`, and `aws-session-token` may be the same as the ones you had provided as Github secrets if you're working with expiring credentials from STS.

</p>
</details>


### Destroy S3 bucket and DynamoDB table for backend Terraform state management

<details>
<summary>Show</summary>
<p>

```bash
echo '{ "aws-access-key-id": "ASIA5K3T6JXVCZR54SP7", "aws-secret-access-key": "2dz2M6Y3SBkiYYc2jlXTQMGoRN6absmlBFiPFuO5", "aws-session-token": "IQoJb3JpZ2luX2VjEPP//////////wEaCX...", "s3-bucket-name": "hosted-zone-management-tfstate-fg78mK", "region": "us-west-2", "action": "destroy" }' | gh workflow run aws-provided-remote-backend-dispatch.yml --json
```
> In this particular example the `aws-access-key-id`, `aws-secret-access-key`, and `aws-session-token` may be the same as the ones you had provided as Github secrets if you're working with expiring credentials from STS.

</p>
</details>


### Teardown keypair, cluster, registry, secrets manager, and secrets

<details>
<summary>Show</summary>
<p>

```bash
echo '{ "footprint": "single", "vpc-cidr": "10.60.0.0/18", "region": "us-west-2", "instance-type": "m5a.xlarge", "container-image-registry-provider": "ecr" }' | gh workflow run aws-e2e-destroy.yml --json
```

</p>
</details>


## Teardown Tanzu Kubernetes Grid clusters and Harbor on AWS

### Destroy Tanzu CloudFormation Stack

<details>
<summary>Show</summary>
<p>

```bash
echo '{ "region": "us-west-2", "action": "destroy" }' | gh workflow run aws-tanzu-cloudformation-stack-dispatch.yml --json
```

</p>
</details>


### Destroy KMS key and alias

<details>
<summary>Show</summary>
<p>

```bash
echo '{ "aws-access-key-id": "ASIA5K3T6JXVCZR54SP7", "aws-secret-access-key": "2dz2M6Y3SBkiYYc2jlXTQMGoRN6absmlBFiPFuO5", "aws-session-token": "IQoJb3JpZ2luX2VjEPP//////////wEaCX...", "region": "us-west-2", "action": "destroy" }' | gh workflow run aws-kms-dispatch.yml --json
```
> In this particular example the `aws-access-key-id`, `aws-secret-access-key`, and `aws-session-token` may be the same as the ones you had provided as Github secrets if you're working with expiring credentials from STS.

</p>
</details>


### Destroy S3 bucket and DynamoDB table for backend Terraform state management

<details>
<summary>Show</summary>
<p>

```bash
echo '{ "aws-access-key-id": "ASIA5K3T6JXVCZR54SP7", "aws-secret-access-key": "2dz2M6Y3SBkiYYc2jlXTQMGoRN6absmlBFiPFuO5", "aws-session-token": "IQoJb3JpZ2luX2VjEPP//////////wEaCX...", "s3-bucket-name": "hosted-zone-management-tfstate-fg78mK", "region": "us-west-2", "action": "destroy" }' | gh workflow run aws-provided-remote-backend-dispatch.yml --json
```
> In this particular example the `aws-access-key-id`, `aws-secret-access-key`, and `aws-session-token` may be the same as the ones you had provided as Github secrets if you're working with expiring credentials from STS.

</p>
</details>


### Teardown keypair, management cluster, workload clusters, secrets manager, and secrets

<details>
<summary>Show</summary>
<p>

```bash
echo '{ "region": "us-west-2", "domain": "zoolabs.me", "control-plane-node-machine-type": "m5a.large", "worker-node-machine-type": "m5a.xlarge" }' | gh workflow run tkg-on-aws-e2e-destroy.yml --json
```

</p>
</details>


## Uninstall Tanzu Application Platform targeting TKG on AWS or EKS

### Uninstall

<details>
<summary>Show</summary>
<p>

```bash
echo '{ "cluster-provider": "tkg»aws", "deployment-name": "tap-full", "dev-namespaces": "demo", "kubeconfig-contents": "dGhpcyBrdWJlY29uZmlnIGlzIGVudGlyZWx5IGZha2UK..." }' | gh workflow run uninstall-tanzu-application-platform-dispatch.yml --json
```
> Note, this dispatch workflow supports variant configuration for targeting Amazon EKS, Azure AKS and Google GKE clusters.  To-date only the following `cluster-provider`s are supported: [ "aks", "eks", "gke", "tkg»aws", "tkg»azure" ].  Also supports variant profiles (e.g., tap-build, tap-iterate, tap-view, tap-run).

</p>
</details>

## Uninstall prereqs in cluster

<details>
<summary>Show</summary>
<p>

```bash
echo '{ "target-cloud": "aws", "kubeconfig-contents": "KVkfThQJXekP3fIgzasYb3lD..." }' | gh workflow run uninstall-tanzu-ingress-dispatch.yml --json
```
> The sample AWS credentials above are for the user account with write permissions to a Route53 hosted zone.  Note, this dispatch workflow supports variant configuration that targets Azure clusters.  To-date only the following `target-clouds`s are supported: [ "aws", "azure" ].  You'll execute this workflow only when the Tanzu Application Platform profile was set to `view` or `full` on target cluster.

```bash
echo '{ "cluster-provider": "eks", "kubeconfig-contents": "KVkfThQJXekP3fIgzasYb3lD..." }' | gh workflow run uninstall-tanzu-standard-repo-dispatch.yml --json
```
> Only execute this command on Non-TKG clusters

</p>
</details>