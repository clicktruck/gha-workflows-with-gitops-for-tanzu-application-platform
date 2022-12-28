# Terraform a new Google Cloud Platform Linux VM (based upon a base image)

Based on the following Terraform examples:

* [google_compute_instance](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance)


Assumes:

* A Google Cloud service account with appropriate role and permissions
* [gcloud](https://cloud.google.com/sdk/docs/install) CLI installed


## Local testing

### Copy sample configuration

```
cp terraform.tfvars.sample terraform.tfvars
```

### Edit `terraform.tfvars`

Amend the values for

* `project`
* `vm_name`
* `region`
* `zone`
* `vm_network`
* `vm_subnetwork`
* `os_image`
* `machine_type`
* `scheduling_preemptible`
* `scheduling_automaticrestart`
* `has_public_ip`


### Specify environment variables

See [Getting Started with the Google Provider > Adding credentials](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/getting_started#adding-credentials)

```
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/credentials.json
```
> Update the value above to be the current path to your service account credentials

### Create bastion

```
./create-bastion.sh
```

### Connect to bastion

```
gcloud compute ssh --zone "{zone}" "bastion-vm"  --project "{project-id}"
```
> Replace `{zone}` and `{project-id}` above respectively with a valid availability zone and google project identifier

### Teardown the bastion

```
./destroy-bastion.sh
```


## Github Action

This action is workflow dispatched [with inputs](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#onworkflow_dispatchinputs).

See [google-bastion-dispatch.yml](../../../.github/workflows/google-bastion-dispatch.yml)
