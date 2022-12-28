# Gitops module for Ingress on Azure

Are you bought-in to managing and auditing updates to Kubernetes resources via Git commits and merge requests?
Would you like to be able to install Ingress (including Contour, Cert-manager configured with Let's Encrypt ClusterIssuer, and ExternalDNS) without the `tanzu` CLI and necessary plugins?
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

Convert the `.tpl` files embedded in the directories underneath `ingress/azure`.

```bash
./to-yaml.sh
```
> After executing this script, you should notice that for each occurrence of a `.tpl` file there should be a corresponding `.yml` file of the same name.  Observe that place-holder values in a `.tpl` file are now substituted with real values in the corresponding `.yml` file.  If upon review you see any un-substituted values in a resultant `.yml` file, go back and edit the `.env` file, then re-run the script.


## Installation

You'll want to `export APP_NAME`.
The value assigned to `APP_NAME` below should match what was previously defined in `.env`.

```bash
kubectl apply -f .prereq
kapp deploy --app $APP_NAME-ns-rbac --file <(ytt --file .init) --diff-changes --yes
kapp deploy --app $APP_NAME --file .install --diff-changes --yes
kapp deploy --app $APP_NAME-ancillary --file .post-install --diff-changes --yes
```


## Verification

```bash
kubectl get app -A
kubectl get packageinstall -A
```


## Removal

```bash
kapp delete --app $APP_NAME-ancillary --yes
kapp delete --app $APP_NAME --yes
kapp delete --app $APP_NAME-ns-rbac --yes
kubectl delete -f .prereq
```
