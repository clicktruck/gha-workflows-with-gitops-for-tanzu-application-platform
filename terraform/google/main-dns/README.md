# Terraform for creating Cloud DNS managed zone

Creates a managed zone (known as the "root zone") to reference domain in Google Cloud DNS.

This sample assumes your authoritative names servers and DNS record information is managed external to Google.

Based on the following Terraform examples:

* [google_dns_managed_zone](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_managed_zone)


Assumes:

* A Google Cloud service account with appropriate role and permissions


## Local testing

### Copy sample configuration

```
cp terraform.tfvars.sample terraform.tfvars
```

### Edit `terraform.tfvars`

Amend the values for

* `project`
* `root_domain`


### Specify environment variables

See [Getting Started with the Google Provider > Adding credentials](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/getting_started#adding-credentials)

```
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/credentials.json
```
> Update the value above to be the current path to your service account credentials

### Create zone

```
./create-zone.sh
```

### Teardown the zone

```
./destroy-zone.sh
```


## Github Action

This action is workflow dispatched [with inputs](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#onworkflow_dispatchinputs).

See [google-main-dns-dispatch.yml](../../../.github/workflows/google-main-dns-dispatch.yml)
