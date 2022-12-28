# Terraform a new AWS Elastic Container Registry

Based on the following Terraform [example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository#example-usage).

Assumes:

* AWS credentials are passed as environment variables
  * See `AWS_*` arguments [here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#environment-variables)


## Local testing

### Copy sample configuration

```
cp terraform.tfvars.sample terraform.tfvars
```

### Edit `terraform.tfvars`

Amend the values for

* `region`
* `registry_name`


### Specify environment variables

```
export AWS_ACCESS_KEY_ID="xxx"
export AWS_SECRET_ACCESS_KEY="xxx"
export AWS_DEFAULT_REGION="xxx"
```
> Replace occurrences of `xxx` above with appropriate values

### Create registry

```
./create-container-registry.sh
```

### Teardown registry

```
./destroy-container-registry.sh
```


## Github Action

This action is workflow dispatched [with inputs](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#onworkflow_dispatchinputs).

See [aws-container-registry-dispatch.yml](../../../.github/workflows/aws-container-registry-dispatch.yml)
