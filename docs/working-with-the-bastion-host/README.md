# Working with the bastion host

The bastion host is derived from a toolset image that provides a curated set of pre-installed tools.

Additional tools will need to be installed after first access.

In the home directory of the bastion host (i.e., `/home/ubuntu`), you will find a collection of scripts.

```
cd $HOME
ls -la *.sh
```

## Installing krew

Script name: `install-krew-and-plugins.sh`.  This script will install [krew](https://krew.sigs.k8s.io) and a curated collection of kubectl [plugins](https://krew.sigs.k8s.io/plugins/).

To install, execute

```
./install-krew-and-plugins.sh
```

## Installing the Tanzu CLI

Script name: `fetch-tanzu-cli.sh`.  This script will install the [Tanzu CLI](https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.6/vmware-tanzu-kubernetes-grid-16/GUID-install-cli.html) and required plugins.

To install, execute

```
./fetch-tanzu-cli.sh {vmware-marketplace-username} {vmware-marketplace-password} {os} {tanzu-cli-version} {tanzu-cli-core-version}
```

For example

```
./fetch-tanzu-cli.sh cphillipson@pivotal.io xxx linux 2.3.0 0.90.1
```

## Installing the Tanzu Application Platform plugins

Script name: `install-tap-plugins.sh`.  This script will install the necessary plugins to install and work with a Tanzu Application Platform.

To install, execute

```
./install-tap-plugins.sh {tanzu-network-api-token}
```
> Fetch the Tanzu Network API Token by signing into https://network.pivotal.io.  Then visit https://network.pivotal.io/users/dashboard/edit-profile to find your API token.


## But what if my bastion host doesn't have the toolset pre-installed?

No worries.  You can [scp](https://linuxconfig.org/scp) a set of scripts to help you fetch and install all the tools you need.

Note: we'll assume your bastion host operating system is Ubuntu Linux 22.04 or better.

```
git clone https://github.com/clicktruck/gha-workflows-with-gitops-for-tanzu-application-platform
cd gha-workflows-with-gitops-for-tanzu-application-platform
scp -i {path-to-private-key-file} -r scripts ubuntu@{bastion-host-ip-address}:/home/ubuntu/
```
> Replace `{path-to-private-key-file}` and `{bastion-host-ip-address}` above with appropriate values

After the scripts have been uploaded to your bastion host, and once you've connected to it via [ssh](https://linuxconfig.org/ssh), you could execute

```
./init.sh
```
