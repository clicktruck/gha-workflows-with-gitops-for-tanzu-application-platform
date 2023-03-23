# Gitops module for Spring Cloud Gateway for K8s

Are you bought-in to managing and auditing updates to Kubernetes resources via Git commits and merge requests?
Would you like to be able to install Spring Cloud Gateway for K8s without the `tanzu` CLI and necessary plugins?
Are you invested in the [Carvel](https://carvel.dev/) toolset and [CRD](https://carvel.dev/kapp-controller/docs/latest/app-spec/)s?

Then, you've come to the right place.


## Prerequisites

These CLIs must be installed

* kubectl
* kapp
* ytt


## Preparation

Copy the `.env.sample` file.

```bash
cp .env.sample .env
```

Edit and save the contents of the `.env` file.

Convert the `.tpl` files embedded in the directories underneath `spring-cloud-gateway`.

```bash
./to-yaml.sh
```
> After executing this script, you should notice that for each occurrence of a `.tpl` file there should be a corresponding `.yml` file of the same name.  Observe that place-holder values in a `.tpl` file are now substituted with real values in the corresponding `.yml` file.  If upon review you see any un-substituted values in a resultant `.yml` file, go back and edit the `.env` file, then re-run the script.


## Installation

First

```
export APP_NAME=spring-cloud-gateway
```

then

```bash
kubectl apply -f .prereq
kapp deploy --app $APP_NAME-ns-rbac --file <(ytt --file .init) --diff-changes --yes
kapp deploy --app $APP_NAME --file .install --diff-changes --yes
```


## Verification

```bash
kubectl get app -A
kubectl get packageinstall -A
```


## Removal

```bash
kapp delete --app $APP_NAME --yes
kapp delete --app $APP_NAME-ns-rbac --yes
kubectl apply -f .prereq
```
