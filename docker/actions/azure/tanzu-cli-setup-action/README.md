# Tanzu CLI Github Action

## Prerequisites

* [Docker](https://docs.docker.com/desktop/)
  * A [subscription](https://www.docker.com/blog/updating-product-subscriptions/) is required for business use.
* An account on the [VMware Marketplace](https://marketplace.cloud.vmware.com/)


## Building

Consult the [Dockerfile](Dockerfile).

To build a portable container image, execute

```bash
docker build -t vmware-tanzu/tanzu-runsh-setup-action .
```


## Launching

Execute

```bash
docker run --rm -it \
  -e CSP_API_TOKEN={csp-api-token} \
  -e TANZU_CLI_VERSION={tanzu-cli-version} -e TANZU_CLI_CORE_VERSION={tanzu-cli-core-version} \
  -e AZURE_SUBSCRIPTION_ID={azure-subscription-id} -e AZURE_AD_TENANT_ID={azure-tenant-id} -e AZURE_AD_CLIENT_ID={azure-ad-client-id} \
  -e AZURE_AD_CLIENT_SECRET={azure-ad-client-secret} \
  -v "/var/run/docker.sock:/var/run/docker.sock:rw" \
  vmware-tanzu/tanzu-cli-setup-action "{command}" {base64-encoded-kubeconfig-contents}
```
> Replace `{csp-api-token}` with [VMware Cloud Service Platform](https://console.cloud.vmware.com) API Token, used for authenticating to the VMware Marketplace.  Replace `{tanzu-cli-version}` and `{tanzu-cli-core-version}` with versions of Tanzu CLI and core CLI respectively.  As new releases become available, you may wish to update the version combinations.  If your account has been granted access, the script will download a tarball, unpack the [Tanzu CLI](https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.6/vmware-tanzu-kubernetes-grid-16/GUID-install-cli.html), install it, then initialize and sync the required plugins.  The tarball and unpacked content will be discarded.  Replace `{base64-encoded-script-contents}`, `{space-separated-script-arguments}`, and `{base64-encoded-kubeconfig-contents}` as well; should be self-evident what to supply.


## Example usage

Dispatch

```yaml
name: "test-dispatch-tanzu-cli"

on:
  workflow_dispatch:
    inputs:
      command:
        description: "The tanzu CLI command to execute"
        required: true
        default: "tanzu version"
      kubeconfig-contents:
        description: "The base64 encoded contents of a .kube/config file that already has the current Kubernetes cluster context set"
        required: true

jobs:
  tanzu-cli:
    uses: ./.github/workflows/test-tanzu-cli.yml
    with:
      command: ${{ github.event.inputs.command }}
    secrets:
      KUBECONFIG_CONTENTS: ${{ github.event.inputs.kubeconfig-contents }}
      CSP_API_TOKEN: ${{ secrets.CSP_API_TOKEN }}
      AZURE_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
      AZURE_AD_TENANT_ID: ${{ secrets.AZURE_AD_TENANT_ID }}
      AZURE_AD_CLIENT_ID: ${{ secrets.AZURE_AD_CLIENT_ID }}
      AZURE_AD_CLIENT_SECRET: ${{ secrets.AZURE_AD_CLIENT_SECRET }}
```

Call

```yaml
name: "test-administer-tanzu-cli"

on:
  workflow_call:
    inputs:
      command:
        description: "The tanzu CLI command to execute"
        required: true
        type: string
    secrets:
      KUBECONFIG_CONTENTS:
        required: true
      CSP_API_TOKEN:
        required: true
      AZURE_SUBSCRIPTION_ID:
        required: true
      AZURE_AD_TENANT_ID:
        required: true
      AZURE_AD_CLIENT_ID:
        required: true
      AZURE_AD_CLIENT_SECRET:
        required: true

jobs:
  run:
    runs-on: ubuntu-22.04

    steps:
    # Checkout the repository to the GitHub Actions runner
    - name: Checkout
      uses: actions/checkout@v4

    # Execute a command with the tanzu CLI
    - name: Execute Tanzu CLI
      uses: ./docker/actions/azure/tanzu-cli-setup-action
      with:
        command: ${{ inputs.command }}
        csp-api-token: ${{ secrets.CSP_API_TOKEN }}
        kubeconfig-contents: ${{ secrets.KUBECONFIG_CONTENTS }}
        azure-subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
        azure-tenant-id: ${{ secrets.AZURE_AD_TENANT_ID }}
        azure-ad-client-id: ${{ secrets.AZURE_AD_CLIENT_ID }}
        azure-ad-client-secret: ${{ secrets.AZURE_AD_CLIENT_SECRET }}

```

## Credits

* [Creating a Docker container action](https://docs.github.com/en/actions/creating-actions/creating-a-docker-container-action)
* [Custom GitHub Actions with Docker](https://dev.to/sethetter/custom-github-actions-with-docker-3ik3)
* [How can I install Docker inside an Alpine container](https://stackoverflow.com/questions/54099218/how-can-i-install-docker-inside-an-alpine-container)
* [How to pass arguments to Shell Script through docker run](https://stackoverflow.com/questions/32727594/how-to-pass-arguments-to-shell-script-through-docker-run)
