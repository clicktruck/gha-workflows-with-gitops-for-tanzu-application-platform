# Terraform a new AWS Linux VM (based upon a base image)

Based on the following Terraform examples:

* [AMI](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami#example-usage)
* [Instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance#basic-example-using-ami-lookup)
* [EIP](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip#single-eip-associated-with-an-instance)


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
* `subnet_id`
* `provisioner_security_group_id`
* `vm_size`
* `toolset_ami_owner`
* `toolset_ami_name`


### Specify environment variables

```
export AWS_ACCESS_KEY_ID="xxx"
export AWS_SECRET_ACCESS_KEY="xxx"
export AWS_DEFAULT_REGION="xxx"
```
> Replace occurrences of `xxx` above with appropriate values

### Create bastion

```
./create-bastion.sh
```

### Teardown the bastion

```
./destroy-bastion.sh
```


## Github Action

This action is workflow dispatched [with inputs](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#onworkflow_dispatchinputs).

See [aws-bastion-dispatch.yml](../../../.github/workflows/aws-bastion-dispatch.yml)

