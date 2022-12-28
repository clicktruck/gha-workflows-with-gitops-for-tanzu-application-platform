# Terraform for installing Harbor

Uses [kubernetes](https://www.terraform.io/docs/providers/kubernetes/index.html), [helm](https://www.terraform.io/docs/providers/helm/index.html) and [carvel](https://github.com/vmware-tanzu/terraform-provider-carvel) Terraform providers to install [Harbor](https://goharbor.io).

Harbor is an open source container image registry that secures images with role-based access control, scans images for vulnerabilities, and signs images as trusted.

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
./create-harbor.sh
```

## Use

A few links for your consideration

* Harbor [administration](https://goharbor.io/docs/2.0.0/administration/)
* [Swagger API](https://editor.swagger.io/?url=https://raw.githubusercontent.com/goharbor/harbor/master/api/v2.0/swagger.yaml)
* Petr Ruzicka's [tutorial](https://ruzickap.github.io/k8s-harbor)

## Remove

```
./destroy-harbor.sh
```
