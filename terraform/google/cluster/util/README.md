# Terraform utility for reporting on available GKE cluster node versions in a region

Based on the following Terraform examples:

* [google_container_engine_versions](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/container_engine_versions)


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
* `region`
* `cluster_version_prefix`
  * just supply `major.minor` version format (e.g., 1.26)


### Specify environment variables

See [Getting Started with the Google Provider > Adding credentials](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/getting_started#adding-credentials)

```
export USE_GKE_GCLOUD_AUTH_PLUGIN=True
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/credentials.json
```
> Update the value above to be the current path to your service account credential

### Run report

```
./run.sh
```

### Cleanup

```
./cleanup.sh
```
