# Terraform a new Google Cloud IAM service account and a Service Identity for Secret Manager instance

Creates:

* a service account (and key file) that all subsequent Terraform modules will use
* a service identity for the Secret Manager API
* a service identity for the Artifact Registry API

Based on the following Terraform examples:

* [google_service_account](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account)
* [google_service_account_key](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account_key)
* [google_project_iam_member](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_iam#google_project_iam_member)
* [google_project_service_identity](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service_identity)

Assumes:

* A Google Cloud principal with Owner privileges


## Local testing

### Copy sample configuration

```
cp terraform.tfvars.sample terraform.tfvars
```

### Edit `terraform.tfvars`

Amend the values for

* `project`


### Specify environment variables

See [Getting Started with the Google Provider > Adding credentials](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/getting_started#adding-credentials)

```
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/credentials.json
```
> Update the value above to be the current path to your principal credentials (otherwise known as the owner account credentials)


### Create IAM resources

```
./create-iam-resources.sh
```

### Destroy IAM resources

```
./destroy-iam-resources.sh
```


## Github Action

This action is workflow dispatched [with inputs](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#onworkflow_dispatchinputs).

See [google-iam-resources-dispatch.yml](../../../.github/workflows/google-iam-resources-dispatch.yml)
