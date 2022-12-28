# Terraform a Udpate/Rollback AWS EKS Storage Class default

Based on the following Terraform examples:

* [annotations](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/annotations).
* [manifest](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest)

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

* `kubeconfig_path`


### Specify environment variables

```
export AWS_ACCESS_KEY_ID="xxx"
export AWS_SECRET_ACCESS_KEY="xxx"
export AWS_DEFAULT_REGION="xxx"
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
./set-kubectl-context.sh {AWS_REGION} {EKS_CLUSTER_NAME}
```

### Rollback storage class default

```
./rollback-cluster-storageclass-default.sh
```

## Github Action

This action is only available as a callable workflow

See [aws-k8s-cluster-storage.yml](../../../.github/workflows/aws-k8s-cluster-storage.yml)

