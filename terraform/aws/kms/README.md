# Terraform a new AWS KMS Key

Based on the following Terraform [example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key#example-usage).

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

* `alias`
* `admin_username`
* `description`
* `tags`


### Specify environment variables

```
export AWS_ACCESS_KEY_ID="xxx"
export AWS_SECRET_ACCESS_KEY="xxx"
export AWS_DEFAULT_REGION="xxx"
```
> Replace occurrences of `xxx` above with appropriate values

### Create KMS key

```
./create-kms.sh
```

### Teardown KMS key

```
./destroy-kms.sh
```


## Github Action

This action is workflow dispatched [with inputs](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#onworkflow_dispatchinputs).

See [aws-kms-dispatch.yml](../../../.github/workflows/aws-kms-dispatch.yml)


## Credits

* Implementation borrowed and adapted from [AWS KMS Customer Managed CMK with Terraform](https://cloudly.engineer/2020/aws-kms-customer-managed-cmk-with-terraform/aws/)
