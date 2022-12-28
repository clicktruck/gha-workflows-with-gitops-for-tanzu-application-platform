# Terraform a Install/Remove AWS EKS Blueprint Addons

Based on the following Terraform [example](https://github.com/aws-ia/terraform-aws-eks-blueprints/tree/main/examples/eks-cluster-with-new-vpc).

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

### Install add-ons

```
./install-cluster-addons.sh
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

### Remove add-ons

```
./remove-cluster-addons.sh
```

## Github Action

This action is only available as a callable workflow

See [aws-k8s-cluster-addons.yml](../../../.github/workflows/aws-k8s-cluster-addons.yml)

