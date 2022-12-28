# Terraform a new AWS EKS Cluster

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

* `eks_cluster_id`
* `vpc_id`
* `desired_nodes`
* `kubernetes_version`
* `ssh_key_name`
* `node_pool_instance_type`
* `provisioner_security_group_id`
* `private_subnet_ids`
* `public_subnet_ids`


### Specify environment variables

```
export AWS_ACCESS_KEY_ID="xxx"
export AWS_SECRET_ACCESS_KEY="xxx"
export AWS_DEFAULT_REGION="xxx"
```
> Replace occurrences of `xxx` above with appropriate values

### Create cluster

```
./create-cluster.sh
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

### Teardown the cluster

```
./destroy-cluster.sh
```

### Obtaining kubeconfig on bastion

For example

```
ssh -o 'IdentitiesOnly yes' -i /home/cphillipson/.ssh/tanzu-bootcamp-tapftw.pem -v ubuntu@35.164.74.103
### Obtain STS credentials and set AWS_* environment variables from OIDC provider (e.g., Cloudgate)
aws eks --region us-west-2 update-kubeconfig --name tap-5517c319205e
kubectl get nodes -o wide
kubectl get po -A -o wide
```
> Note we update `.kube/config` using the `aws` CLI which is pre-installed on the bastion instance.


## Github Action

This action is workflow dispatched [with inputs](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#onworkflow_dispatchinputs).

See [aws-k8s-cluster-dispatch.yml](../../../.github/workflows/aws-k8s-cluster-dispatch.yml)


## Troubleshooting

* [Increasing service quota for Amazon EC2 instances](https://aws.amazon.com/premiumsupport/knowledge-center/ec2-instance-limit/)
* [Delete EKS Cluster & Node Groups](https://www.stacksimplify.com/aws-eks/eks-cluster/delete-eks-cluster-nodegroup/)
  * [Hanging node group after delete](https://github.com/weaveworks/eksctl/issues/1325#issuecomment-615679727)

## Elsewhere

* [tf4k8s](https://github.com/pacphi/tf4k8s/tree/master/modules/cluster/eks)
