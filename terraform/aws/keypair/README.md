# Terraform a new AWS Keypair

Based on the following Terraform [example](https://github.com/cloudposse/terraform-aws-key-pair#usage).

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
* `ssh_key_name`


### Specify environment variables

```
export AWS_ACCESS_KEY_ID="xxx"
export AWS_SECRET_ACCESS_KEY="xxx"
export AWS_DEFAULT_REGION="xxx"
```
> Replace occurrences of `xxx` above with appropriate values

### Create keypair

```
./create-keypair.sh
```

### Teardown keypair

```
./destroy-keypair.sh
```


## Github Action

This action is workflow dispatched [with inputs](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#onworkflow_dispatchinputs).

See [aws-keypair-dispatch.yml](../../../.github/workflows/aws-keypair-dispatch.yml)
