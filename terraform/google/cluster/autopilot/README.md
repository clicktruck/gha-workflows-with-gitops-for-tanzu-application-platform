# Terraform a new Autopilot GKE cluster

Based on the following Terraform examples:

* [google_container_cluster](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster)
* [google_compute_ssl_policy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_ssl_policy)
* [google_gke_hub_membership](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/gke_hub_membership)


Assumes:

* A Google Cloud service account with appropriate role and permissions
* [gcloud](https://cloud.google.com/sdk/docs/install) CLI installed
  * kubectl installed
  * gke-gcloud-auth-plugin installed


## Local testing

### Copy sample configuration

```
cp terraform.tfvars.sample terraform.tfvars
```

### Edit `terraform.tfvars`

Amend the values for

* `project`
* `region`
* `cluster_name`
* `cluster_version_prefix`
* `vpc_network_name`
* `subnetwork_name`
* `master_ipv4_cidr_block_28`
* `enable_private_endpoint`
* `master_authorized_networks_cidr_list`


### Specify environment variables

See [Getting Started with the Google Provider > Adding credentials](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/getting_started#adding-credentials)

```
export USE_GKE_GCLOUD_AUTH_PLUGIN=True
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/credentials.json
```
> Update the value above to be the current path to your service account credentials

### Create cluster

```
./create-cluster.sh
```

### Connect to cluster

* See [Important changes to Kubectl authentication are coming in GKE v1.25](https://cloud.google.com/blog/products/containers-kubernetes/kubectl-auth-changes-in-gke)

If `enable_private_endpopint` was set to `false, then you may connect to the GKE cluster from anywhere; otherwise you'll need to [create a bastion host](../../bastion/README.md), ssh into it, then connect to the GKE cluster

```
gcloud container clusters list
gcloud container clusters get-credentials {cluster-name} --region={region}
kubectl get svc -A
```
> Replace `{cluster-name}` and `{region}` above respectively with a valid cluster name and region

### Teardown the cluster

```
./destroy-cluster.sh
```


## Github Action

This action is workflow dispatched [with inputs](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#onworkflow_dispatchinputs).

See [google-autopilot-k8s-cluster-dispatch.yml](../../../.github/workflows/google-autopilot-k8s-cluster-dispatch.yml)



## Credits

Implementation inspired by [Fabian Lee](https://github.com/fabianlee/gcp-gke-clusters-ingress).
