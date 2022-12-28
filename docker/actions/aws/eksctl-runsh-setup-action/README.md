# eksctl Run Shell Script Github Action

## Prerequisites

* [Docker](https://docs.docker.com/desktop/)
  * A [subscription](https://www.docker.com/blog/updating-product-subscriptions/) is required for business use.


## Building

Consult the [Dockerfile](Dockerfile).

To build a portable container image, execute

```bash
docker build -t vmware-tanzu/eksctl-runsh-setup-action .
```


## Launching

Execute

```bash
docker run --rm -it -e AWS_ACCESS_KEY_ID={aws-access-key-id} -e AWS_SECRET_ACCESS_KEY='{aws-secret-access-key}' -e AWS_SESSION_TOKEN={aws-session-token} vmware-tanzu/eksctl-runsh-setup-action {base64-encoded-script-contents} '{space-separated-script-arguments}'
```
> Replace `{aws-access-key-id}`, `{aws-secret-access-key}` and `{aws-session-token}` with credentials you use to authenticate to AWS.  Replace `{base64-encoded-script-contents}` and `{space-separated-script-arguments}` as well; should be self-evident what to supply.


## Example usage

Dispatch

```yaml
name: "test-dispatch-eksctl-runsh"

on:
  workflow_dispatch:
    inputs:
      script-contents:
        description: "The base64 encoded contents of a shell script"
        required: true
      script-arguments:
        description: "A space separated set of arguments that the script will consume"
        required: true

jobs:
  tanzu-cli:
    uses: ./.github/workflows/test-eksctl-runsh.yml
    secrets:
      SCRIPT_CONTENTS: ${{ github.event.inputs.script-contents }}
      SCRIPT_ARGS: ${{ github.event.inputs.script-arguments }}
      AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
      AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
      AWS_SESSION_TOKEN: ${{ secrets.AWS_SESSION_TOKEN }}
```

Call

```yaml
name: "test-administer-eksctl-runsh"

on:
  workflow_call:
    secrets:
      SCRIPT_CONTENTS:
        required: true
      SCRIPT_ARGS:
        required: true
      AWS_ACCESS_KEY_ID:
        required: true
      AWS_SECRET_ACCESS_KEY:
        required: true
      AWS_SESSION_TOKEN:
        required: false

jobs:
  run:
    runs-on: ubuntu-20.04

    steps:
    # Checkout the repository to the GitHub Actions runner
    - name: Checkout
      uses: actions/checkout@v3

    # Execute a script
    - name: Execute shell script that may invoke a series of kubectl or tanzu CLI commands
      uses: ./docker/actions/aws/eksctl-runsh-setup-action
      with:
        script-contents: ${{ secrets.SCRIPT_CONTENTS }}
        script-arguments: ${{ secrets.SCRIPT_ARGS}}
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-session-token: ${{ secrets.AWS_SESSION_TOKEN }}
```

## Credits

* [Creating a Docker container action](https://docs.github.com/en/actions/creating-actions/creating-a-docker-container-action)
* [Custom GitHub Actions with Docker](https://dev.to/sethetter/custom-github-actions-with-docker-3ik3)
* [How to pass arguments to Shell Script through docker run](https://stackoverflow.com/questions/32727594/how-to-pass-arguments-to-shell-script-through-docker-run)

