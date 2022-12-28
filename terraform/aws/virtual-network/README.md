# Terraform a new AWS VPC

Based on the following Terraform [example](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest).

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
* `vpc_cidr`
* `private_subnet_cidrs`
* `public_subnet_cidrs`
* `availability_zones`

### Specify environment variables

```
export AWS_ACCESS_KEY_ID="xxx"
export AWS_SECRET_ACCESS_KEY="xxx"
export AWS_DEFAULT_REGION="xxx"
```
> Replace occurrences of `xxx` above with appropriate values

### Create network

```
./create-network.sh
```

### Teardown the network

```
./destroy-network.sh
```


## Github Action

This action is workflow dispatched [with inputs](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#onworkflow_dispatchinputs).

See [aws-virtual-network-dispatch.yml](../../../.github/workflows/aws-virtual-network-dispatch.yml)
