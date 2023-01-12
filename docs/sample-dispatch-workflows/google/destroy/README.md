# Sample Github CLI Dispatch Workflows targeting Google Cloud Platform

Credentials or sensitive configuration shared in the examples below are for illustrative purposes only.

See [gh workflow run](https://cli.github.com/manual/gh_workflow_run) for additional options.

## Table of contents

* [Destroy KMS key](#destroy-kms-key)
* [Destroy Cloud Storage bucket for backend Terraform state management](#destroy-cloud-storage-bucket-for-backend-terraform-state-management)
* [Teardown Google Cloud DNS Hosted Zones](#teardown-google-cloud-dns-hosted-zones)
  * [Destroy hosted zone for base domain](#destroy-hosted-zone-for-base-domain)
  * [Destroy hosted zone for child domain](#destroy-hosted-zone-for-child-domain)
* [Teardown GKE and GCR on Google](#teardown-gke-and-gcr-on-google)
  * [Teardown cluster, registry, secrets manager, and secrets](#teardown-cluster-registry-secrets-manager-and-secrets)
* [Teardown GKE and Harbor on Google](#teardown-gke-and-harbor-on-google)
  * [Teardown workload clusters, secrets manager, and secrets](#teardown-workload-clusters-secrets-manager-and-secrets)
* [Uninstall Tanzu Application Platform targeting GKE](#uninstall-tanzu-application-platform-targeting-gke)
  * [Uninstall prereqs from cluster](#uninstall-prereqs-from-cluster)
  * [Uninstall](#uninstall)


## Destroy KMS key

<details>
<summary>Show</summary>
<p>

```bash
echo '{ "google-project-id": "xx-xxxxx", "google-service-account-key": "YW0uZ3NlcnZpY2VhY2NvdW50LmNvbSIKfQo=", "region": "us-west2", "action": "destroy" }' | gh workflow run google-kms-dispatch.yml --json
```

</p>
</details>


## Destroy Cloud Storage bucket for backend Terraform state management

<details>
<summary>Show</summary>
<p>

```bash
echo '{ "google-project-id": "xx-xxxxx", "google-service-account-key": "YW0uZ3NlcnZpY2VhY2NvdW50LmNvbSIKfQo=", "region": "us-west2", "bucket-name": "tap", "action": "destroy" }' | gh workflow run google-provided-remote-backend-dispatch.yml --json
```

</p>
</details>


## Teardown Google Cloud DNS Hosted Zones

We'll assume hosted zones are managed in the same Google account.  But there's nothing that stops you from provisioning them in an alternate project.


### Destroy hosted zone for base domain

<details>
<summary>Show</summary>
<p>

```bash
echo '{ "google-project-id": "xx-xxxxx", "google-service-account-key": "YW0uZ3NlcnZpY2VhY2NvdW50LmNvbSIKfQo=", "domain": "ironleg.me", "region": "us-west2", "action": "destroy" }' | gh workflow run google-main-dns-dispatch.yml --json
```

</p>
</details>

> Note: your domain registrar may or may not be your cloud provider.  If not, you will need to update nameserver entries for your domain using the NS record from the Cloud DNS hosted zone in your domain registrar.

### Destroy hosted zone for child domain

<details>
<summary>Show</summary>
<p>

```bash
echo '{ "google-project-id": "xx-xxxxx", "google-service-account-key": "YW0uZ3NlcnZpY2VhY2NvdW50LmNvbSIKfQo=", "root-domain-zone-name": "ironleg-zone", "subdomain": "apps", "action": "destroy" }' | gh workflow run google-child-dns-dispatch.yml --json
```

</p>
</details>


## Teardown GKE and GCR on Google

### Teardown cluster, registry, secrets manager, and secrets

<details>
<summary>Show</summary>
<p>

```bash
echo '{ "footprint": "single-cluster", "vpc-network-name": "tap-demo-network", "machine-type": "e2-standard-4", "region": "us-west2", "container-image-registry-provider": "google-container-registry" }' | gh workflow run google-e2e-destroy.yml --json
```
> You can also teardown w/ `"footprint": "multi-cluster"`. And you may also consider provisioning w/ `"container-image-registry-provider": "google-artifact-registry"`

</p>
</details>


## Teardown GKE and Harbor on Google

### Teardown workload clusters, secrets manager, and secrets

<details>
<summary>Show</summary>
<p>

```bash
echo '{ "footprint": "single-cluster", "vpc-network-name": "tap-demo-network", "machine-type": "e2-standard-4", "region": "us-west2", "container-image-registry-provider": "harbor" }' | gh workflow run google-e2e-destroy.yml --json
```
> In the above example `google-access-key-id` and `google-secret-access-key` are the credentials for managing a Cloud DNS hosted zone (i.e., for base domain).  You can also teardown w/ `"footprint": "multi-cluster"` too.

</p>
</details>


## Uninstall Tanzu Application Platform targeting GKE

Steps below assume you have a _target cluster_, a _container image registry_, and a _Cloud DNS_ hosted zone setup.  If you ran a provisioning workflow above, you may [find](https://cloud.google.com/secret-manager/docs/creating-and-accessing-secrets#access) sensitive configuration in a [Secrets Manager](https://cloud.google.com/secret-manager/docs/destroy-secret) instance.


## Uninstall prereqs from cluster


```bash
echo '{ "tkg-version": "v1.6.1", "cluster-provider": "gke", "kubeconfig-contents": "KVkfThQJXekP3fIgzasYb3lD..." }' | gh workflow run uninstall-tanzu-standard-repo-dispatch.yml --json
```
> Only executed on Non-TKG clusters.  This is actually automatically installed if you executed [ google-k8s-cluster-dispatch, azure-k8s-cluster-dispatch, google-k8s-cluster-dispatch ] workflows.

```bash
echo '{ "domain": "ironleg.me", "email-address": "admin@ironleg.me", "google-project-id": "xx-xxxxx", "google-service-account-key": "YW0uZ3NlcnZpY2VhY2NvdW50LmNvbSIKfQo=", "google-region": "us-west2", "cluster-provider": "gke", "kubeconfig-contents": "KVkfThQJXekP3fIgzasYb3lD..." }' | gh workflow run uninstall-tanzu-ingress-dispatch.yml --json
```
> Execute this command for clusters configured to host `view` or `full` Tanzu Application Platform profiles.  Provides Contour ingress including a Let's Encrypt ClusterIssuer and External-DNS configuration.  The sample Google credentials above are for the user account with write permissions to a Cloud DNS hosted zone.  Note, this dispatch workflow supports variant configuration for targeting Azure AKS and Google GKE clusters.  To-date only the following `cluster-provider`s are supported: [ "aks", "gke", "gke", "tkg»google", "tkg»azure" ].

</p>
</details>


### Uninstall

Single-cluster

<details>
<summary>Show</summary>
<p>

```bash
echo '{ "deployment-name": "tap-full", "cluster-provider": "gke", "kubeconfig-contents": "dGhpcyBrdWJlY29uZmlnIGlzIGVudGlyZWx5IGZha2UK..." }' | gh workflow run uninstall-tanzu-application-platform-dispatch.yml --json
```
> Note, this dispatch workflow supports variant configuration for targeting Amazon GKE, Azure AKS and Google GKE clusters.  To-date only the following `cluster-provider`s are supported: [ "aks", "gke", "gke", "tkg»aws", "tkg»azure" ].  Other optional options may apply depending on choice of provider.  Update the `deployment-name` suffix to target a particular TAP profile.


</p>
</details>
