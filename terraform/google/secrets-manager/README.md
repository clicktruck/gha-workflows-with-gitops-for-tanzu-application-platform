# Terraform a new instance of Google Cloud Secrets Manager

Prerequisites:

* Service Usage API must be [enabled](https://cloud.google.com/service-usage/docs/set-up-development-environment)
* Secrets Manager API must be [enabled](https://cloud.google.com/secret-manager/docs/accessing-the-api)

Based on the following Terraform examples:

* [google_kms_crypto_key](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/kms_crypto_key)
* [google_secret_manager_secret](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret)


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
* `keyring`
* `keyring_location`
* `secret_manager_instance_name`
* `secret_manager_instance_location`


### Specify environment variables

See [Getting Started with the Google Provider > Adding credentials](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/getting_started#adding-credentials)

```
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/credentials.json
```
> Update the value above to be the current path to your service account credentials

### Create secrets manager instance

```
./create-secrets-manager.sh
```

### Teardown the secrets manager instance

```
./destroy-secrets-manager.sh
```


## Github Action

This action is workflow dispatched [with inputs](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#onworkflow_dispatchinputs).

See [google-secrets-manager-dispatch.yml](../../../.github/workflows/google-secrets-manager-dispatch.yml)
