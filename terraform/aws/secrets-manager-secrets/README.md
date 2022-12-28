# Terraform addition of secrets to an existing AWS Secrets Manager instance

Based on the following Terraform [example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version#key-value-pairs).

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

* `secrets_manager_name`
* `secret_map`


### Specify environment variables

```
export AWS_ACCESS_KEY_ID="xxx"
export AWS_SECRET_ACCESS_KEY="xxx"
export AWS_DEFAULT_REGION="xxx"
```
> Replace occurrences of `xxx` above with appropriate values

### Add new secrets

```
./create-secrets-manager-secrets.sh
```

### Retrieving secrets

See https://docs.aws.amazon.com/secretsmanager/latest/userguide/retrieving-secrets.html#retrieving-secrets_cli.

### Remove secrets

```
./destroy-secrets-manager-secrets.sh
```


## Github Action

This action is workflow dispatched [with inputs](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#onworkflow_dispatchinputs).

See [aws-secrets-manager-secrets-dispatch.yml](../../../.github/workflows/aws-secrets-manager-secrets-dispatch.yml)
