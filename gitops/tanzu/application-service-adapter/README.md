# Gitops module for Application Service Adapter for Tanzu Application Platform

Are you bought-in to managing and auditing updates to Kubernetes resources via Git commits and merge requests?
Would you like to be able to install Application Service Adapter for Tanzu Application Platform without the `tanzu` CLI and necessary plugins?
Are you invested in the [Carvel](https://carvel.dev/) toolset and [CRD](https://carvel.dev/kapp-controller/docs/latest/app-spec/)s?

Then, you've come to the right place.


## Prerequisites

These CLIs must be installed

* cf
* kubectl
* kapp
* ytt

You should also have pre-installed

* the [Tanzu Application Platform](../application-platform)
  * also see [Installing Prerequisites](https://docs-staging.vmware.com/en/Application-Service-Adapter-for-VMware-Tanzu-Application-Platform/1.0/tas-adapter/GUID-install-prerequisites.html#installing-prerequisites-0)


## Preparation

Copy the `.env.sample` file.

```bash
cp .env.sample .env
```

Edit and save the contents of the `.env` file.

Convert the `.tpl` files embedded in the directories underneath `application-service-adapter`.

```bash
./to-yaml.sh
```
> After executing this script, you should notice that for each occurrence of a `.tpl` file there should be a corresponding `.yml` file of the same name.  Observe that place-holder values in a `.tpl` file are now substituted with real values in the corresponding `.yml` file.  If upon review you see any un-substituted values in a resultant `.yml` file, go back and edit the `.env` file, then re-run the script.


## Installation

First

```
export APP_NAME=tas-adapter-for-tap
```

then

```bash
kapp deploy --app $APP_NAME-ns-rbac --file <(ytt --file .init) --diff-changes --yes
kapp deploy --app $APP_NAME --file .install --diff-changes --yes
```


## Verification

```bash
kubectl get app -A
kubectl get packageinstall -A
kubectl -n tanzu-system-ingress get service envoy -o jsonpath='{.status.loadBalancer.ingress[*].ip}'
kubectl get httpproxy korifi-api-proxy -n tas-adapter-system
```


## Usage

You'll need to authenticate, then create a `RoleBinding`, before actually being able to exercise the [cf](https://docs.cloudfoundry.org/cf-cli/install-go-cli.html) CLI (version 8.7.1 or better).

Follow [these instructions](https://docs.vmware.com/en/Application-Service-Adapter-for-VMware-Tanzu-Application-Platform/1.1/tas-adapter/install.html#assign-the-admin-role-to-a-user).


## Removal

```bash
kapp delete --app $APP_NAME --yes
kapp delete --app $APP_NAME-ns-rbac --yes
```
