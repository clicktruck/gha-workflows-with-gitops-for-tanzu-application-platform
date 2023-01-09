# Get Base64-encoded ~/.kube/config from an EKS cluster Action

## Prerequisites

* [Docker](https://docs.docker.com/desktop/)
  * A [subscription](https://www.docker.com/blog/updating-product-subscriptions/) is required for business use.


## Building

Consult the [Dockerfile](Dockerfile).

To build a portable container image, execute

```bash
docker build -t vmware-tanzu/eks-kubeconfig-action .
```


## Launching

Execute

```bash
docker run --rm -it -e AWS_ACCESS_KEY_ID={aws-access-key-id} -e AWS_SECRET_ACCESS_KEY='{aws-secret-access-key}' -e AWS_SESSION_TOKEN={aws-session-token} vmware-tanzu/eks-kubeconfig-action {cluster-name} {aws-region}
```
> Replace `{aws-access-key-id}`, `{aws-secret-access-key}` and `{aws-session-token}` with credentials you use to authenticate to AWS.  Replace `{cluster-name}` and `{aws-region}` with the name of the cluster you want to obtain the base64-encoded ~/.kube/config from and the AWS region it was deployed into, respectively.


## Example usage

Dispatch

```yaml
name: "test-dispatch-eks-kubeconfig"

on:
  workflow_dispatch:
    inputs:
      cluster-name:
        description: "The name of the EKS cluster"
        required: true
      aws-region:
        description: "The AWS region where the EKS cluster is running"
        required: true

jobs:
  tanzu-cli:
    uses: ./.github/workflows/test-eks-kubeconfig.yml
    secrets:
      CLUSTER_NAME: ${{ github.event.inputs.cluster-name }}
      AWS_REGION: ${{ github.event.inputs.aws-region }}
      AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
      AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
      AWS_SESSION_TOKEN: ${{ secrets.AWS_SESSION_TOKEN }}
```

Call

```yaml
name: "test-administer-eks-kubeconfig"

on:
  workflow_call:
    secrets:
      CLUSTER_NAME:
        required: true
      AWS_REGION:
        required: true
      AWS_ACCESS_KEY_ID:
        required: true
      AWS_SECRET_ACCESS_KEY:
        required: true
      AWS_SESSION_TOKEN:
        required: false

jobs:
  run:
    runs-on: ubuntu-22.04

    outputs:
      b64kubeconfig: ${{ steps.obtain_kubeconfig.outputs.b64kubeconfig }}

    steps:
    # Checkout the repository to the GitHub Actions runner
    - name: Checkout
      uses: actions/checkout@v3

    - name: Obtain base64 encoded .kube/config contents
      id: obtain_kubeconfig
      uses: ./docker/actions/aws/eks-kubeconfig-action
      with:
        cluster-name: ${{ secrets.CLUSTER_NAME }}
        aws-region: ${{ secrets.AWS_REGION }}
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-session-token: ${{ secrets.AWS_SESSION_TOKEN }}
```

## Credits

* [Creating a Docker container action](https://docs.github.com/en/actions/creating-actions/creating-a-docker-container-action)
* [Custom GitHub Actions with Docker](https://dev.to/sethetter/custom-github-actions-with-docker-3ik3)
* [How to pass arguments to Shell Script through docker run](https://stackoverflow.com/questions/32727594/how-to-pass-arguments-to-shell-script-through-docker-run)
