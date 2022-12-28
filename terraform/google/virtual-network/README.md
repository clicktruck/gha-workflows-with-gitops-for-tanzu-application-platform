# Terraform a new Google Cloud Virtual Private Cloud (i.e., network, subnetworks, firewall)

Based on the following Terraform examples:

* [google_compute_network](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network)
* [google_compute_subnetwork](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork)
* [google_compute_firewall](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall)
* [google_compute_address](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address)


Assumes:

* A Google Cloud service account with appropriate role and permissions


## Local testing

### Copy sample configuration

```
cp terraform.tfvars.sample terraform.tfvars
```

### Edit `terraform.tfvars`

Amend the values for

* `project`
* `vpc_network_name`
* `vpc_subnetwork_region`


### Specify environment variables

See [Getting Started with the Google Provider > Adding credentials](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/getting_started#adding-credentials)

```
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/credentials.json
```
> Update the value above to be the current path to your service account credentials

### Create VPC

```
./create-virtual-network.sh
```

### Teardown the VPC

```
./destroy-virtual-network.sh
```


## Github Action

This action is workflow dispatched [with inputs](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#onworkflow_dispatchinputs).

See [google-virtual-network-dispatch.yml](../../../.github/workflows/google-virtual-network-dispatch.yml)



## Credits

Implementation inspired by [Fabian Lee](https://github.com/fabianlee/gcp-gke-clusters-ingress).
