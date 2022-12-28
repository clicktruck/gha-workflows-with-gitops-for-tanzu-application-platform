# Gitops modules

* [Tanzu Standard repository](tanzu/standard)
* [Tanzu Data Services repository](tanzu/data-services)
* Ingress for a target cloud provider
  * [AWS](tanzu/ingress/aws)
  * [Azure](tanzu/ingress/azure)
  * [Google Cloud](tanzu/ingress/google)
  * [Oracle Cloud](tanzu/ingress/oracle)
* [Tanzu Application Platform](tanzu/application-platform)
* [Application Service Adapter for Tanzu Application Platform](tanzu/application-service-adapter)
* [Learning Center supplemental](tanzu/learningcenter/supplemental)
  * also see [Add or view Learning Center Workshops](../docs/add-or-view-learningcenter-workshops/README.md)
* [Spring Cloud Gateway for Kubernetes](tanzu/spring-cloud-gateway)

## Assumptions

Workstation host OS is either MacOS or Linux.

## Prerequisites

(if leveraging these modules locally)

* [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl) CLI
  * version installed should match target cluster
* [Carvel](https://carvel.dev) toolset is installed on workstation
  * includes kapp and ytt CLIs
* `KUBECONFIG` enviroment variable or `$HOME/.kube/config` file present with current context set targeting cluster
* Cloud CLI installed and authorized
  * [aws](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
  * [az](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
  * [gcloud](https://cloud.google.com/sdk/docs/install)
  * [oci](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm)

(on target cluster)

* [Cluster Essentials for VMware Tanzu](https://docs.vmware.com/en/Cluster-Essentials-for-VMware-Tanzu/1.3/cluster-essentials/GUID-deploy.html) is installed
  * includes kapp-controller and secretgen-controller
  * also see [Bootstrapping Cluster Essentials for VMware Tanzu](https://github.com/alexandreroman/tanzu-cluster-essentials-bootstrap)
