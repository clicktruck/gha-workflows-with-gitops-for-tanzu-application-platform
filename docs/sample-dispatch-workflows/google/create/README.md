# Sample Github CLI Dispatch Workflows targeting Google Cloud Platform

Credentials or sensitive configuration shared in the examples below are for illustrative purposes only.

See [gh workflow run](https://cli.github.com/manual/gh_workflow_run) for additional options.

## Table of contents

* [Create fork of this repo](#create-fork-of-this-repo)
* [Create Toolset Image on Google](#create-toolset-image-on-google)
* [Create IAM service account](#create-iam-service-account)
* [Create KMS key](#create-kms-key)
* [Create Cloud Storage bucket for backend Terraform state management](#create-cloud-storage-bucket-for-backend-terraform-state-management)
* [Provision Google Cloud DNS Hosted Zones](#provision-google-cloud-dns-hosted-zones)
  * [Create hosted zone for base domain](#create-hosted-zone-for-base-domain)
  * [Create hosted zone for child domain](#create-hosted-zone-for-child-domain)
* [Provision GKE and GCR on Google](#provision-gke-and-gcr-on-google)
  * [Provision cluster, registry, secrets manager, and secrets](#provision-cluster-registry-secrets-manager-and-secrets)
* [Provision GKE and Harbor on Google](#provision-gke-and-harbor-on-google)
  * [Provision workload clusters, secrets manager, and secrets](#provision-workload-clusters-secrets-manager-and-secrets)
* [Relocate TAP images from Tanzu Network](#relocate-tap-images-from-tanzu-network)
* [Install Tanzu Application Platform targeting GKE](#install-tanzu-application-platform-targeting-gke)
  * [Install prereqs into cluster](#install-prereqs-into-cluster)
  * [Install](#install)


## Create fork of this repo

<details>
<summary>Show</summary>
<p>

```bash
gh repo fork pacphi/gha-workflows-with-gitops-for-tanzu-application-platform
```

</p>
</details>


## Create toolset image on Google

<details>
<summary>Show</summary>
<p>

```bash
echo '{ "instanceType": "e2-standard-4", "region": "us-west2-a" }' | gh workflow run google-ubuntu-22_04.yml --json
```

</p>
</details>

## Create IAM service account

Follow the instructions in [this guide](../../../../terraform/google/iam/README.md) on your local workstation to create a service account with appropriate roles and permissions associated that will be employed by all the Github Actions dispatch workflows below.

## Create KMS key

<details>
<summary>Show</summary>
<p>

```bash
echo '{ "google-project-id": "xx-xxxxx", "google-service-account-key": "YW0uZ3NlcnZpY2VhY2NvdW50LmNvbSIKfQo=", "region": "us-west2", "action": "create" }' | gh workflow run google-kms-dispatch.yml --json
```

</p>
</details>


## Create Cloud Storage bucket for backend Terraform state management

<details>
<summary>Show</summary>
<p>

```bash
echo '{ "google-project-id": "xx-xxxxx", "google-service-account-key": "YW0uZ3NlcnZpY2VhY2NvdW50LmNvbSIKfQo=", "region": "us-west2", "bucket-name": "tap", "action": "create" }' | gh workflow run google-provided-remote-backend-dispatch.yml --json
```

</p>
</details>


## Provision Google Cloud DNS Hosted Zones

We'll assume hosted zones are managed in the same Google account.  But there's nothing that stops you from provisioning them in an alternate project.


### Create hosted zone for base domain

<details>
<summary>Show</summary>
<p>

```bash
echo '{ "google-project-id": "xx-xxxxx", "google-service-account-key": "YW0uZ3NlcnZpY2VhY2NvdW50LmNvbSIKfQo=", "domain": "ironleg.me", "region": "us-west2", "action": "create" }' | gh workflow run google-main-dns-dispatch.yml --json
```

</p>
</details>

> Note: your domain registrar may or may not be your cloud provider.  If not, you will need to update nameserver entries for your domain using the NS record from the Cloud DNS hosted zone in your domain registrar.

### Create hosted zone for child domain

<details>
<summary>Show</summary>
<p>

```bash
echo '{ "google-project-id": "xx-xxxxx", "google-service-account-key": "YW0uZ3NlcnZpY2VhY2NvdW50LmNvbSIKfQo=", "root-domain-zone-name": "ironleg-zone", "subdomain": "apps", "action": "create" }' | gh workflow run google-child-dns-dispatch.yml --json
```

</p>
</details>


## Provision GKE and GCR on Google

### Provision cluster, registry, secrets manager, and secrets

<details>
<summary>Show</summary>
<p>

```bash
echo '{ "footprint": "single-cluster", "vpc-network-name": "tap-demo-network", "machine-type": "e2-standard-4", "region": "us-west2", "email-address": "admin@ironleg.me", "domain": "ironleg.me", "container-image-registry-provider": "google-container-registry" }' | gh workflow run google-e2e.yml --json
```
> You can also provision w/ `"footprint": "multi-cluster"`. And you may also consider provisioning w/ `"container-image-registry-provider": "google-artifact-registry"`

</p>
</details>


## Provision GKE and Harbor on Google

### Provision workload clusters, secrets manager, and secrets

<details>
<summary>Show</summary>
<p>

```bash
echo '{ "footprint": "single-cluster", "vpc-network-name": "tap-demo-network", "machine-type": "e2-standard-4", "region": "us-west2", "email-address": "admin@ironleg.me", "domain": "ironleg.me", "container-image-registry-provider": "harbor" }' | gh workflow run google-e2e.yml --json
```
> In the above example `google-access-key-id` and `google-secret-access-key` are the credentials for managing a Cloud DNS hosted zone (i.e., for base domain).  You can also provision w/ `"footprint": "multi-cluster"` too.

</p>
</details>


### Add new project to Harbor

<details>
<summary>Show</summary>
<p>

```bash
echo '{ "username": "admin", "password": "flipp3r", "api-endpoint": "harbor.ironleg.me", "project": "tanzu" }' | gh workflow run create-harbor-project-dispatch.yml --json
```
> In the above example, if `project` is set to a value other than `tanzu`, then you'll need to review and edit the configuration values under `tap.registry.repositories` in [tap-value-input.yml](../../../gitops/tanzu/application-platform/base/tap-values-input.yml).

</p>
</details>


## Install Tanzu Application Platform targeting GKE

Steps below assume you have a _target cluster_, a _container image registry_, and a _Cloud DNS_ hosted zone setup.  If you ran a provisioning workflow above, you may [find](https://cloud.google.com/secret-manager/docs/creating-and-accessing-secrets#access) sensitive configuration in a [Secrets Manager](https://cloud.google.com/secret-manager/docs/create-secret) instance.


## Install prereqs into cluster

<details>
<summary>Show</summary>
<p>

```bash
echo '{ "cluster-provider": "gke", "kubeconfig-contents": "KVkfThQJXekP3fIgzasYb3lD..." }' | gh workflow run install-tanzu-cluster-essentials-dispatch.yml --json
```
> Only executed on Non-TKG clusters.  This is actually automatically installed if you executed [ google-k8s-cluster-dispatch, azure-k8s-cluster-dispatch, google-k8s-cluster-dispatch ] workflows.

```bash
echo '{ "tkg-version": "v2023.7.31_update.1", "cluster-provider": "gke", "kubeconfig-contents": "KVkfThQJXekP3fIgzasYb3lD..." }' | gh workflow run install-tanzu-standard-repo-dispatch.yml --json
```
> Only executed on Non-TKG clusters.  This is actually automatically installed if you executed [ google-k8s-cluster-dispatch, azure-k8s-cluster-dispatch, google-k8s-cluster-dispatch ] workflows.

```bash
echo '{ "domain": "ironleg.me", "email-address": "admin@ironleg.me", "google-project-id": "xx-xxxxx", "google-service-account-key": "YW0uZ3NlcnZpY2VhY2NvdW50LmNvbSIKfQo=", "google-region": "us-west2", "cluster-provider": "gke", "kubeconfig-contents": "KVkfThQJXekP3fIgzasYb3lD..." }' | gh workflow run install-tanzu-ingress-dispatch.yml --json
```
> Execute this command for clusters configured to host `view` or `full` Tanzu Application Platform profiles.  Provides Contour ingress including a Let's Encrypt ClusterIssuer and External-DNS configuration.  The sample Google credentials above are for the user account with write permissions to a Cloud DNS hosted zone.  Note, this dispatch workflow supports variant configuration for targeting Azure AKS and Google GKE clusters.  To-date only the following `cluster-provider`s are supported: [ "aks", "gke", "gke", "tkg»google", "tkg»azure" ].

</p>
</details>


### Relocate TAP images from Tanzu Network

Do this once

```bash
echo '{ "container-image-registry-url": "harbor.ironleg.me", "container-image-registry-username": "admin", "container-image-registry-password": "cEBzc3cwcmQlCg==", "container-image-registry-provider": "google-on-harbor", "google-project-id": "xx-xxxxx" }' | gh workflow relocate-tap-images-from-tanzu-network-to-container-registry-dispatch.yml --json
```

### Install

Single-cluster

<details>
<summary>Show</summary>
<p>

```bash
echo '{ "tap-install-details": "apps.ironleg.me;admin@ironleg.me;default;https://github.com/pacphi/tap-gui-catalog/blob/main/catalog-info.yaml", "container-image-registry-provider": "harbor-on-google", "container-image-registry-connection-details": "harbor.ironleg.me;admin;cEBzc3cwcmQlCg==;tanzu/build-service;tanzu/supply-chain", "cluster-provider": "gke", "active-profile": "full", "kubeconfig-contents": "dGhpcyBrdWJlY29uZmlnIGlzIGVudGlyZWx5IGZha2UK..." }' | gh workflow run install-tanzu-application-platform-dispatch.yml --json
```
> Note, this dispatch workflow supports variant configuration for targeting Amazon GKE, Azure AKS and Google GKE clusters.  To-date only the following `cluster-provider`s are supported: [ "aks", "gke", "gke", "tkg»aws", "tkg»azure" ].  Other optional options may apply depending on choice of provider.  Remember to base64-encode the _password_ if the _host_ in `container-image-registry-connection-details` is Google Container Registry or Google Artifact Registry!


</p>
</details>

Multi-cluster

<details>
<summary>Show</summary>
<p>

```bash
echo '{ "google-project-id": "xx-xxxxx", "secrets-manager-instance-name": "tap-secret-store", "domain": "apps.ironleg.me", "email-address": "admin@ironleg.me", "dev-namespace": "default", "backstage-catalog": "https://github.com/pacphi/tap-gui-catalog/blob/main/catalog-info.yaml", "container-image-registry-provider": "harbor-on-google"}' | gh workflow run multi-cluster-tanzu-application-platform-install-on-google-dispatch.yml --json
```
> In this context, `container-image-registry-provider` can be: [ "google-artifact-registry", "google-container-registry", "harbor-on-google" ]

</p>
</details>