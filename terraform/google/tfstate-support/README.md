# Terraform a new Google Cloud Storage Bucket for Terraform State support

Based on the following Terraform examples:

* [google_kms_crypto_key](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/kms_crypto_key)
* [google_storage_bucket](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket)
* [Using kms to encrypt buckets in cloud storage](https://github.com/hashicorp/terraform-provider-google/issues/7695)

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
* `location`
* `bucket_name`
* `keyring`
  * if supplied GCS bucket is encrypted using a customer-managed encryption key (CMEK)


### Specify environment variables

See [Getting Started with the Google Provider > Adding credentials](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/getting_started#adding-credentials)

```
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/credentials.json
```
> Update the value above to be the current path to your service account credentials

### Create Terraform state support

```
./create-tfstate-support.sh
```

### Teardown Terraform state support

```
./destroy-tfstate-support.sh
```


## Github Action

This action is workflow dispatched [with inputs](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#onworkflow_dispatchinputs).

See [setup-google-provided-remote-backend-dispatch.yml](../../../.github/workflows/setup-google-provided-remote-backend-dispatch.yml)


## Limitations

Github actions do **not** currently consume the CMEK-variant of this implementation.  At least not until Terraform has support for a CMEK.  Watch this [issue](https://github.com/hashicorp/terraform/issues/24967).
