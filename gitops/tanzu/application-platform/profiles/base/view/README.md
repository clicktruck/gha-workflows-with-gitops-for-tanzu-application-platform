## Tanzu Application Platform Configuration Supplemental

### View Profile

This directory contains a YTT template file named [tap-values-view.yml](tap-values-view.yml) which will be consumed as data-values.  It may contain cluster configuration necessary for the View cluster's Application Live View component to communicate with a Build cluster and one or more Run clusters.

### Onboarding a new cluster or clusters

Use the [onboard-cluster-to-app-live-view-dispatch](../../../../../../../actions/workflows/onboard-cluster-to-app-live-view-dispatch.yml) dispatch workflow to onboard one or more clusters.

The `observed-clusters` input must be a single-line, base64-encoded string that would contain something like the following array-map configuration:

```yaml
- name: build-cluster
  cluster-provider: eks
  base64-encoded-kubeconfig-contents: YWFhCg==
  credentials:
    aws-session-token: kl=1
    aws-access-key-id: dddN
    aws-secret-access-key: kkVXZ
    aws-region: us-west-2
- name: run-cluster-1
  cluster-provider: gke
  base64-encoded-kubeconfig-contents: YmJiCg==
  credentials:
    base64-encoded-google-service-account-json-file-contents: LLzCRo9==
    region: us-west1
- name: run-cluster-2
  cluster-provider: aks
  base64-encoded-kubeconfig-contents: Y2NjCg==
```

### Github Action workflow implementation details

Consult the [onboard-cluster-to-app-live-view-dispatch](../../../../../.github/workflows/onboard-cluster-to-app-live-view-dispatch.yml) and [onboard-cluster-to-app-live-view.yml](../../../../../.github/workflows/onboard-cluster-to-app-live-view.yml) workflows.

We're updating the profile configuration on a cluster that previously had the Tanzu Application Platform view profile installed.

To do this, we employ a script named [observe-clusters.sh](../../../../../../scripts/observe-clusters.sh) to construct a configuration block that will be added to a Go-template [tap-install-secrets.tpl](../../../.init/tap-install-secrets.tpl) at `#! observed-clusters`.

A configuration block starts with:

```yaml
  observed:
    clusters:
```

and may nest one or more indexed configuration key-value pairs, e.g.

```yaml
      kv1:
        name: "foo"
        url: some-url
        token: kLhhg678m2==
        skipTLS: true
        skipMetrics: true
```

This configuration is then leveraged by the [render-template](https://github.com/marketplace/actions/render-template) Github Action to render the final form.

### Extension

The script and YTT template must be updated if you would like to request observing more than the number of clusters whose configuration details have value placeholders.

In `observe-clusters.sh` you would update this line:

```bash
MAX_OBSERVED_CLUSTERS=5
```
> Increase the value to be the maximum number of clusters you may wish to observe.

In `tap-values-view.yml` you would add another block like:

```yaml
#@ if data.values.tap.observed.clusters.kvN.name != "" && data.values.tap.observed.clusters.kvN.url != "" && data.values.tap.observed.clusters.kvN.token != ""
- name: #@ data.values.tap.observed.clusters.kvN.name
  url: #@ data.values.tap.observed.clusters.kvN.url
  authProvider: serviceAccount
  serviceAccountToken: #@ data.values.tap.observed.clusters.kvN.token
  skipTLSVerify: #@ data.values.tap.observed.clusters.kvN.skipTLS
  skipMetricsLookup: #@ data.values.tap.observed.clusters.kvN.skipMetrics
  #@ if data.values.tap.observed.clusters.kvN.skipTLS != true:
  caData: #@ data.values.tap.observed.clusters.kvN.ca
  #@ end
#@ end
```
> Replace occurrences of `N` above with a positive integer number (e.g., 6).  Continue to add blocks like this for the desired number of clusters you wish to observe.

## Background

* [Tanzu Application Platform Sample Configuration](https://gist.github.com/clicktruck/72b1b7fd231714dbe24cb39298d17a48)
* [Update Tanzu Application Platform GUI to view resources on multiple clusters](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.5/tap/tap-gui-cluster-view-setup.html#update-tanzu-application-platform-gui-to-view-resources-on-multiple-clusters-1)
