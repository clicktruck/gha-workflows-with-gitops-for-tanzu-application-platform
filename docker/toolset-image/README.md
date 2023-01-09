# K8s Toolset

An Ubuntu 22.04-based Docker image of curated tools for use with Kubernetes environments.

## Prerequistes

* [Docker](https://docs.docker.com/desktop/) or [nerdctl](https://github.com/containerd/nerdctl)

> Notice: if using Docker a [subscription](https://www.docker.com/blog/updating-product-subscriptions/) is required for business use.


## Building

If you want to build a portable container image, then execute

```
./build.sh
```
> You may add `docker` or `nerdctl` as an argument to script execution in order to dictate which container build engine is employed to build the image.  If no argument is supplied, the script employs Docker.

## Launching

Execute

```
docker run --rm -it vmware-tanzu/k8s-toolset /bin/bash
```

or

```
nerdctl container run --rm -it vmware-tanzu/k8s-toolset /bin/bash
```

## Launching with ability to create a Tanzu Kubernetes Grid (TKG) cluster

In order to create TKG clusters we need to be able to use docker for the `kind` bootstrap process. Using the command below will set the network to `host` allowing the `kind` cluster's network to be accessible from the container, as well as mounting the docker socket to give access to the underlying host's docker daemon.

```bash
docker run -it -v /var/run/docker.sock:/var/run/docker.sock -v ${PWD}:/workspace  --network=host docker.io/vmware-tanzu/k8s-toolset
```

Before attempting to create a TKG _management_ or _workload_ cluster you will first need to fetch the tanzu CLI, install it, and configure plugins.

Consult the `scripts` directory inside the container.  There's a handy script to do just that.

```
cd scripts
./fetch-tanzu-cli.sh {csp-api-token} linux {tanzu-cli-version} {tanzu-cli-core-version}
```
> Replace `{csp-api-token}` with [VMware Cloud Service Platform](https://console.cloud.vmware.com) API Token, used for authenticating to the VMware Marketplace.  Replace `{tanzu-cli-version}` and `{tanzu-cli-core-version}` with versions of Tanzu CLI and core CLI respectively.  As new releases become available, you may wish to update the version combinations.  If your account has been granted access, the script will download a tarball, unpack the [Tanzu CLI](https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.6/vmware-tanzu-kubernetes-grid-16/GUID-install-cli.html), install it, then initialize and sync the required plugins.  The tarball and unpacked content will be discarded.

See [Working with the Bastion Host](../../docs/working-with-the-bastion-host/README.md) for details on additional scripts you can run to fetch, install and configure plugins for `kubectl` and/or `tanzu` CLIs.
