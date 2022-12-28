# Terraform a new Google Cloud KMS

Based on the following Terraform examples:

* [Google KMS Terraform Module](https://registry.terraform.io/modules/terraform-google-modules/kms/google)


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
* `service_account_name`


### Specify environment variables

See [Getting Started with the Google Provider > Adding credentials](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/getting_started#adding-credentials)

```
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/credentials.json
```
> Update the value above to be the current path to your service account credentials

### Create kms

```
./create-kms.sh
```

### Destroy the kms

```
./destroy-kms.sh
```
> Note: This only deletes the keys in a keyring.  The keyring is not destroyed! See this StackOverflow [inquiry](https://stackoverflow.com/questions/54440878/editing-or-deleting-a-key-ring-from-the-console).


## Github Action

This action is workflow dispatched [with inputs](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#onworkflow_dispatchinputs).

See [google-kms-dispatch.yml](../../../.github/workflows/google-kms-dispatch.yml)
