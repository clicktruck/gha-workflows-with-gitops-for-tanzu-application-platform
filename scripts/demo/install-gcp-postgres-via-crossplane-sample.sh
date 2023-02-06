#!/bin/bash

# A script based upon: https://docs.vmware.com/en/Services-Toolkit-for-VMware-Tanzu-Application-Platform/0.9/svc-tlk/usecases-consuming_gcp_sql_with_crossplane.html

# Requirements:

# * gcloud CLI - Provisions cloud resources (i.e., VPC, RDS instances)
# * helm CLI - Deploys Crossplane
# * Tanzu Application Platform (TAP) – Installation of TAP 1.2.x or greater utilizing the
#     “iterate” profile or other profile that has deployed out-of-the-box supply chains,
#     out-of-the-box templates, services toolkit, and service bindings
# * kubectl – You will use this to manage Kubernetes resources
# * Tanzu CLI – You will use this to execute Tanzu specific operations
# * You will need permissive access to the TAP Kubernetes cluster with kubectl and Tanzu CLI tools

APP_NAME="spring-petclinic"
GCP_POJECT_ID="REPLACE_ME"
GCP_SERVICE_ACCOUNT_NAME="crossplane-cloudsql"
SERVICE_INSTANCE_NAMESPACE="service-instances"
GCP_INSTANCE_NAME="gcp-postres-db-1"
GCP_INSTANCE_TYPE="db-custom-1-3840"
GCP_POSTGRES_VERSION="POSTGRES_14"
GCP_REGION="us-west2"
SERVICE_INSTANCE_NAMESPACE="service-instances"
CROSSPLANE_NAMESPACE="crossplane-system"
CROSSPLANE_PROVIDER_NAME="crossplane-provider-gcp"
CROSSPLANE_PROVIDER_VERSION=v0.21.0 # @see https://github.com/crossplane-contrib/provider-gcp/releases for latest available version
CROSSPLANE_PROVIDER_SECRET_NAME="gcp-provider-creds"
WORKLOAD_NAMESPACE="workloads"
DEPLOY_WORKLOAD="false"
INSTALL_CROSSPLANE="false"

set -x

# Create namespace to host all service instances
kubectl create ns ${SERVICE_INSTANCE_NAMESPACE}

if [ "true" == "$INSTALL_CROSSPLANE" ]; then

# Create namespace to host Crossplane
kubectl create ns ${CROSSPLANE_NAMESPACE}

# Install Crossplane
helm repo add crossplane-stable https://charts.crossplane.io/stable
helm repo update
helm install crossplane --namespace ${CROSSPLANE_NAMESPACE} crossplane-stable/crossplane \
  --set 'args={--enable-external-secret-stores}' --wait

# Validate Crossplane was installed
kubectl get pods -n ${CROSSPLANE_NAMESPACE}

# Install GCP provider for Crossplane
kubectl apply --wait=true -f -<<EOF
---
apiVersion: pkg.crossplane.io/v1
kind: Provider
metadata:
  name: ${CROSSPLANE_PROVIDER_NAME}
spec:
  package: crossplane/provider-gcp:${CROSSPLANE_PROVIDER_VERSION}
EOF

# See the health of the provider that was just installed
kubectl get provider.pkg.crossplane.io ${CROSSPLANE_PROVIDER_NAME}

# Create a new GCP Service Account and gives it permissions to manage CloudSQL databases
# which are necessary to use Crossplane to manage CloudSQL instances
gcloud iam service-accounts create "${GCP_SERVICE_ACCOUNT_NAME}" --project "${GCP_PROJECT_ID}"
gcloud projects add-iam-policy-binding "${GCP_PROJECT_ID}" \
  --role="roles/cloudsql.admin" \
  --member "serviceAccount:${GCP_SERVICE_ACCOUNT_NAME}@${GCP_PROJECT_ID}.iam.gserviceaccount.com"
gcloud iam service-accounts keys create creds.json --project "${GCP_PROJECT_ID}" --iam-account "${GCP_SERVICE_ACCOUNT_NAME}@${GCP_PROJECT_ID}.iam.gserviceaccount.com"

# Create secret
kubectl create secret generic ${CROSSPLANE_PROVIDER_SECRET_NAME} -n ${CROSSPLANE_NAMESPACE} --from-file=creds=./creds.json --wait=true

# Clean-up creds on file-system
rm -f creds.json

# Configure the Crossplane provider
kubectl apply --wait=true -f -<<EOF
---
apiVersion: aws.crossplane.io/v1beta1
kind: ProviderConfig
metadata:
  name: default
spec:
  projectID: ${GCP_PROJECT_ID}
  credentials:
    source: Secret
    secretRef:
      namespace: ${CROSSPLANE_NAMESPACE}
      name: ${CROSSPLANE_PROVIDER_SECRET_NAME}
      key: creds
EOF

# Wait for the provider to become healthy
kubectl -n ${CROSSPLANE_NAMESPACE} wait provider/${CROSSPLANE_PROVIDER_NAME} \
  --for=condition=Healthy=True --timeout=3m

fi


# Define composite resource type w/ custom CompositeResourceDefinition (XRD)
kubectl apply --wait=true -f -<<EOF
---
apiVersion: apiextensions.crossplane.io/v1
kind: CompositeResourceDefinition
metadata:
  name: xpostgresqlinstances.bindable.database.example.org
spec:
  claimNames:
    kind: PostgreSQLInstance
    plural: postgresqlinstances
  connectionSecretKeys:
    - type
    - provider
    - host
    - port
    - database
    - username
    - password
  group: bindable.database.example.org
  names:
    kind: XPostgreSQLInstance
    plural: xpostgresqlinstances
  versions:
    - name: v1alpha1
      referenceable: true
      schema:
        openAPIV3Schema:
          properties:
            spec:
              properties:
                parameters:
                  properties:
                    storageGB:
                      type: integer
                  required:
                    - storageGB
                  type: object
              required:
                - parameters
              type: object
          type: object
      served: true
EOF

# Create a corresponding composition
# A new VPC will be created to host all service instances
kubectl apply --wait=true -f -<<EOF
---
apiVersion: apiextensions.crossplane.io/v1
kind: Composition
metadata:
  labels:
    provider: gcp
  name: xpostgresqlinstances.bindable.gcp.database.example.org
spec:
  compositeTypeRef:
    apiVersion: bindable.database.example.org/v1alpha1
    kind: XPostgreSQLInstance
  publishConnectionDetailsWithStoreConfigRef:
    name: default
  resources:
  - base:
      apiVersion: database.gcp.crossplane.io/v1beta1
      kind: CloudSQLInstance
      spec:
        forProvider:
          databaseVersion: ${GCP_POSTGRES_VERSION}
          region: ${GCP_REGION}
          settings:
            dataDiskType: PD_SSD
            ipConfiguration:
              authorizedNetworks:
              - value: 0.0.0.0/0 # not recommended for production deployments!
              ipv4Enabled: true
            tier: ${GCP_INSTANCE_TYPE}
        writeConnectionSecretToRef:
          namespace: crossplane-system
    connectionDetails:
    - name: type
      value: postgresql
    - name: provider
      value: gcp
    - name: database
      value: postgres
    - fromConnectionSecretKey: username
    - fromConnectionSecretKey: password
    - name: host
      fromConnectionSecretKey: endpoint
    - name: port
      type: FromValue
      value: "5432"
    name: cloudsqlinstance
    patches:
    - fromFieldPath: metadata.uid
      toFieldPath: spec.writeConnectionSecretToRef.name
      transforms:
      - string:
          fmt: '%s-postgresql'
          type: Format
        type: string
      type: FromCompositeFieldPath
    - fromFieldPath: spec.parameters.storageGB
      toFieldPath: spec.forProvider.settings.dataDiskSizeGb
      type: FromCompositeFieldPath
EOF

# Grant RBAC permissions to the Services Toolkit to enable reading the secrets specified by the class
kubectl apply --wait=true -f -<<EOF
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: stk-secret-reader
  labels:
    servicebinding.io/controller: "true"
rules:
- apiGroups:
  - ""
  resources:
  - secrets
  verbs:
  - get
  - list
  - watch
EOF

# Provision GCP CloudSQL PostgreSQL instance
kubectl apply --wait=true -f -<<EOF
---
apiVersion: bindable.database.example.org/v1alpha1
kind: PostgreSQLInstance
metadata:
  name: ${GCP_INSTANCE_NAME}
  namespace: ${SERVICE_INSTANCE_NAMESPACE}
spec:
  parameters:
    storageGB: 20
  compositionSelector:
    matchLabels:
      provider: gcp
  publishConnectionDetailsTo:
    name: ${GCP_INSTANCE_NAME}
    metadata:
      labels:
        services.apps.tanzu.vmware.com/class: cloudsql-postgres
EOF

# Verify the CloudSQL Postgresql database instance was created
gcloud sql instances list


# Wait for database to be ready for connections
kubectl wait --for=condition=Ready=true postgresqlinstances.bindable.database.example.org ${GCP_INSTANCE_NAME} \
  --timeout=10m

# Address a bug in Crossplane 1.7.2 onwards with the --enable-external-secret-stores feature gate enabled
# where the controller will fail to clean up a local secret created by the field .spec.publishConnectionDetailsTo
# after the deletion of the claim. A workaround is to temporarily give the crossplane controller the necessary
# i.e. permissions
kubectl create clusterrole crossplane-cleaner --verb=delete --resource=secrets
kubectl create clusterrolebinding crossplane-cleaner --clusterrole=crossplane-cleaner --serviceaccount=${CROSSPLANE_NAMESPACE}:crossplane

if [ "$DEPLOY_WORKLOAD" == "true" ]; then

# Create a ClusterInstanceClass
kubectl apply --wait=true -f -<<EOF
---
apiVersion: services.apps.tanzu.vmware.com/v1alpha1
kind: ClusterInstanceClass
metadata:
  name: cloudsql-postgres
spec:
  description:
    short: GCP CloudSQL Postgresql database instances
  pool:
    kind: Secret
    labelSelector:
      matchLabels:
        services.apps.tanzu.vmware.com/class: cloudsql-postgres
    fieldSelector: type=connection.crossplane.io/v1alpha1
EOF

  # Show available classes of service instances
  tanzu service classes list

  # Show claimable instances  belonging to the CloudSQL PostgreSQL class
  tanzu services claimable list --class cloudsql-postgres

  # Create a claim
  tanzu service claim create cloudsql-claim \
    --resource-name ${GCP_INSTANCE_NAME} \
    --resource-kind Secret \
    --resource-api-version v1

  # Obtain the claim reference
  tanzu service claim list -o wide

  # Create an application workload that consumes the claimed RDS PostgreSQL database. In this example, --service-ref is set to the claim reference obtained earlier.
  tanzu apps workload create ${APP_NAME} \
    --namespace ${WORKLOAD_NAMESPACE}
    --git-repo https://github.com/sample-accelerators/spring-petclinic \
    --git-branch main \
    --git-tag tap-1.2 \
    --type web \
    --label app.kubernetes.io/part-of=spring-petclinic \
    --annotation autoscaling.knative.dev/minScale=1 \
    --env SPRING_PROFILES_ACTIVE=postgres \
    --service-ref db=services.apps.tanzu.vmware.com/v1alpha1:ResourceClaim:cloudsql-claim

  set +x

  # Follow the build
  echo "❯ To check in on status of the deployment, execute: \n\ttanzu apps workloads tail ${APP_NAME} -n ${WORKLOAD_NAMESPACE} --since 10m --timestamp"

  # Learn how to engage with app once deployed
  echo "❯ To verify that the application has successfully deployed and is running, execute: \n\ttanzu apps workloads get ${APP_NAME} -n ${WORKLOAD_NAMESPACE}"
fi