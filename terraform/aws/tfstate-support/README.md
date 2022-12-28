# Terraform a new AWS S3 Bucket and Dynamo DB Table for Terraform State support

Based on the following Terraform [example](https://technology.doximity.com/articles/terraform-s3-backend-best-practices).

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
* `bucket_name`


### Specify environment variables

```
export AWS_ACCESS_KEY_ID="xxx"
export AWS_SECRET_ACCESS_KEY="xxx"
export AWS_DEFAULT_REGION="xxx"
```
> Replace occurrences of `xxx` above with appropriate values

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

See [setup-aws-provided-remote-backend-dispatch.yml](../../../.github/workflows/setup-aws-provided-remote-backend-dispatch.yml)
