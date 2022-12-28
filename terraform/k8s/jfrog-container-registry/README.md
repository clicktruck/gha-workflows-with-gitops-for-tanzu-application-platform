# Terraform for installing JFrog Container Registry

Uses [kubernetes](https://www.terraform.io/docs/providers/kubernetes/index.html), [helm](https://www.terraform.io/docs/providers/helm/index.html) and [carvel](https://github.com/vmware-tanzu/terraform-provider-carvel) Terraform providers to install [JFrog Container Registry](https://hub.helm.sh/charts/jfrog/artifactory-jcr).

JFrog Container Registry is a free Artifactory edition with Docker and Helm repositories support.

Starts with the assumption that you have already provisioned a cluster.

## Prerequisites

The following should be installed and configured in advance

* Contour
* Cert-manager
* External-DNS


## Copy sample configuration

```
cp terraform.tfvars.sample terraform.tfvars
```

## Edit `terraform.tfvars`

Amend the values for

* `domain`
* `acme_mail`
* `kubeconfig_path`

## Install

```
./create-jcr.sh
```

### First-time configuration

Obtain the value of `jcr_endpoint` from your Terraform output.

Visit the site in your favorite browser and authenticate with

* username: `admin`
* password: `password`

Once authenticated, an onboarding wizard will start guiding you through the steps to setup your instance of JFrog Container Registry.

* Scroll through the text of the `EULA Confirmation`, then click the checkbox next to the `I have read and agree to the terms and conditions stated in the EULA` to confirm you have read it, then click the `Next` button.
* Click the `Next` button without entering an email on the `Subscribe for Newsletter` step.
* Enter a password in the `New Password` and `Confirm Password` fields of the `Reset Admin Password` step, then click the `Next` button.
* Enter a url in the `Select Base URL` field of the `Set base URL` step, then click the `Next` button.  (The value you enter here should be the same as the `jcr_endpoint` value from your Terraform output).
* Click the `Next` button accepting the defaults in the `Configure Default Proxy` step.  (We're choosing not to configure or secure a proxy).
* Choose to create a `Local Repository`. Click the `Docker` icon and enter a name for your repository (e.g., `images`), accept the defaults for other options, then click `Save & Finish`.
  * You may choose to repeat this process in order to create a `Helm` chart repository; in that case you'd click on the `Helm` icon instead and supply a unique name (e.g., `helm-charts`).

> The steps above are illustrated in the JFrog Container Registry `Getting Started` documentation [here](https://www.jfrog.com/confluence/display/JFROG/Get+Started%3A+JFrog+Container+Registry).


## Use

So, how do you push a container image into the Docker repository hosted in your instance of JFrog Container Registry?

Here's a sample work flow

```
docker login https://jcr.daf.ironleg.me
docker pull busybox
docker tag busybox:latest jcr.daf.ironleg.me/docker/busybox:1.0
docker push jcr.daf.ironleg.me/docker/busybox:1.0
```

The following documentation provides more detailed information about how to work with a

* [Docker Registry](https://www.jfrog.com/confluence/display/JCR6X/Getting+Started+with+JFrog+Container+Registry+as+a+Docker+Registry)
* [Helm Registry](https://www.jfrog.com/confluence/display/JCR6X/Helm+Registry)


## Remove

```
./destroy-jcr.sh
```

## Troubleshooting

* If you forgot to accept the EULA on first-time configuration, see this Stack Overflow [answer](https://stackoverflow.com/questions/60095151/how-can-i-automatically-accept-artifactory-eula) to remedy.