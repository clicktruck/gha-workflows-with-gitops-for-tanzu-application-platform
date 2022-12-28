# Terraform a new Google Cloud Secrets Manager Secrets

Stores a key-value map of secrets

Based on the following Terraform examples:

* [google_secret_manager_secret](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/secret_manager_secret)
* [google_secret_manager_secret_version](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_version)


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
* `secrets_manager_instance_name`
* `secrets_key_value_map`


### Specify environment variables

See [Getting Started with the Google Provider > Adding credentials](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/getting_started#adding-credentials)

```
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/credentials.json
```
> Update the value above to be the current path to your service account credentials

### Add secrets

```
./create-secrets-manager-secrets.sh
```


### Accessing a secret

At a terminal prompt (with environment variable set above), type:

```
gcloud secrets versions access {version_id} --secret="{secret-manager-instance-name}"
```
> Replace `{version-id}` and `secret-manager-instance-name` above with appropriate values

For example

```
❯ gcloud secrets versions access latest --secret="tap-secret-store"

{"foo": "bar"}
```

### Remove secrets

```
./destroy-secrets-manager-secrets.sh
```


## Github Action

This action is workflow dispatched [with inputs](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#onworkflow_dispatchinputs).

See [google-secrets-manager-secrets-dispatch.yml](../../../.github/workflows/google-secrets-manager-secrets-dispatch.yml)
