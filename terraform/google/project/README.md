# Terraform a new Google Cloud project

Based on the following Terraform examples:

* [google_project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project)

Assumes:

* A Google Cloud principal with Owner privileges


## Local testing

### Copy sample configuration

```
cp terraform.tfvars.sample terraform.tfvars
```

### Edit `terraform.tfvars`

Amend the values for

* `billing_account_id`
* `project`


### Specify environment variables

See [Getting Started with the Google Provider > Adding credentials](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/getting_started#adding-credentials)

```
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/credentials.json
```
> Update the value above to be the current path to your principal credentials


### Create project

```
./create-project.sh
```

### Destroy the project

```
./destroy-project.sh
```


## Github Action

This action is workflow dispatched [with inputs](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#onworkflow_dispatchinputs).

See [google-project-dispatch.yml](../../../.github/workflows/google-project-dispatch.yml)
