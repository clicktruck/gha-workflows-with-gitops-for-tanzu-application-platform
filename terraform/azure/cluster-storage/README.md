# Terraform for updating or resetting the Azure AKS Storage Class default

Based on the following Terraform examples:

* [annotations](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/annotations).
* [manifest](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest)

Assumes:

* Azure credentials are passed as environment variables
  * See `ARM_*` arguments [here](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs#environment-variables)


## Local testing

### Copy sample configuration

```
cp terraform.tfvars.sample terraform.tfvars
```

### Edit `terraform.tfvars`

Amend the values for

* `kubeconfig_path`


### Specify environment variables

```
export ARM_CLIENT_ID=xxx
export ARM_CLIENT_SECRET=xxx
export ARM_SUBSCRIPTION_ID=xxx
export ARM_TENANT_ID=xxx
```
> Replace occurrences of `xxx` above with appropriate values

### Update storage class default

```
./update-cluster-storageclass-default.sh
```

### List available clusters

```
./list-clusters.sh
```

### Update kubeconfig

Use the name and location of the cluster you just created to update `kubeconfig` and set the current context for `kubectl`

```
./set-kubectl-context.sh {AKS_CLUSTER_NAME} {RESOURCE_GROUP_NAME}
```

### Rollback storage class default

```
./rollback-cluster-storageclass-default.sh
```

## Github Action

This action is only available as a callable workflow

See [azure-k8s-cluster-storage.yml](../../../.github/workflows/azure-k8s-cluster-storage.yml)

