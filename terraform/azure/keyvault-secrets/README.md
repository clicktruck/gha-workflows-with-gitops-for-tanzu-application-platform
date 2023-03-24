# Terraform secrets for Azure Key Vault

Based on the following Terraform [example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_secrets_secret#example-usage).

Assumes:

* Azure credentials are passed as environment variables
  * See `ARM_*` arguments [here](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs#argument-reference)


## Local testing

### Copy sample configuration

```
cp terraform.tfvars.sample terraform.tfvars
```

### Edit `terraform.tfvars`

Amend the values for

* `resource_group_name`
* `kv_name`
* `secret_map`

### Specify environment variables

```
export ARM_CLIENT_ID=xxx
export ARM_CLIENT_SECRET=xxx
export ARM_SUBSCRIPTION_ID=xxx
export ARM_TENANT_ID=xxx
```
> Replace occurrences of `xxx` above with appropriate values

### Create secrets

```
./create-secrets.sh
```

### Retrieve secret from Keyvault

See https://learn.microsoft.com/en-us/azure/key-vault/secrets/quick-create-cli#retrieve-a-secret-from-key-vault.

For example

```
# Login with service principal that has Keyvault Secrets Officer role assigned
az login --service-principal -u <clientId> -p <clientSecret> --tenant <tenantId>
# Fetch list of key vaults
az keyvault list -o table
# Fetch list of secret names from a key vault
az keyvault secret list --vault-name <keyVaultName> -o table
# Fetch a secret value
az keyvault secret show --vault-name <keyVaultName> --name <secretName> -o table
```

### Teardown secrets

```
./destroy-secrets.sh
```


## Github Action

This action is workflow dispatched [with inputs](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#onworkflow_dispatchinputs).

See [azure-keyvault-secrets-dispatch.yml](../../../.github/workflows/azure-keyvault-secrets-dispatch.yml)
