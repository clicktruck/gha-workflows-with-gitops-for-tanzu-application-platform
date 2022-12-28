# Build a Google Compute Image

## Prerequisites

* Google Compute service account credentials
* Google Cloud SDK ([gcloud](https://cloud.google.com/sdk/docs/install))
* [Packer](https://www.packer.io/downloads)


## Authenticate

A number of options exist, but this simplest may be to

```
gcloud auth application-default login
```

Then if you're on MacOs or Linux

```
export GOOGLE_APPLICATION_CREDENTIALS="$HOME/.config/gcloud/application_default_credentials.json"
```

or Windows

```
export GOOGLE_APPLICATION_CREDENTIALS="%APPDATA%/gcloud/application_default_credentials.json"
```


## Use Packer to build and upload an image

Copy common scripts into place

```
cp ../../../../scripts/init.sh .
cp ../../../../scripts/kind-load-cafile.sh .
cp ../../../../scripts/inventory.sh .
cp ../../../../scripts/install-krew-and-plugins.sh .
```

Fetch Tanzu CLI

```
cp ../../../../scripts/fetch-tanzu-cli.sh .
./fetch-tanzu-cli.sh {CSP_API_TOKEN} linux {TANZU_CLI_VERSION} {TANZU_CLI_CORE_VERSION}
```
> Replace `{CSP_API_TOKEN}` with the [VMware Cloud Service Platform](https://console.cloud.vmware.com) API Token, used for authenticating to the VMware Marketplace.  Replace `{TANZU_CLI_VERSION}` and `{TANZU_CLI_CORE_VERSION}` with a supported (and available) version numbers for the CLI you wish to embed in the container image.  If your account has been granted access, the script will download a tarball, extract the [Tanzu CLI](https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.6/vmware-tanzu-kubernetes-grid-16/GUID-install-cli.html) and place it into a `dist` directory.  The tarball and other content will be discarded.  (The script has "smarts" built-in to determine whether or not to fetch a version of the CLI that may have already been fetched and placed in the `dist` directory).

Fetch and install TAP plugins

```
cp ../../../../scripts/install-tap-plugins.sh
```
> You're just copying this script into place.

Fetch and install oci CLI

```
cp ../../../../scripts/fetch-and-install-oci-cli.sh .
```
> You're just copying this script into place.


Type the following to build the image

```
packer init .
packer fmt .
packer validate .
packer inspect .
packer build -only='{BUILD_NAME}.*' .
```
> Replace `{BUILD_NAME}` with one of [ `standard`, `with-tanzu` ]; a file provisioner uploads the Tanzu CLI into your image when set to `with-tanzu`.  You have the option post image build to fetch and install or upgrade it via [mkpcli](https://github.com/vmware-labs/marketplace-cli).  The [fetch-tanzu-cli.sh](../../../../scripts/fetch-tanzu-cli.sh) script is also packaged and available for your convenience in the resultant image.

>In ~10 minutes you should notice a `manifest.json` file where within the `artifact_id` contains a reference to the image ID.


### Available overrides

You may wish to size the instance and/or choose a different region to host the image.

```
packer build --var project_id=fe-cphillipson --var zone=europe-central2-a -only='standard.*' .
```
> Consult the `variable` blocks inside [googlecompute.pkr.hcl](googlecompute.pkr.hcl)



## For your consideration

* [Google Compute](https://www.packer.io/docs/builders/googlecompute) Builder
