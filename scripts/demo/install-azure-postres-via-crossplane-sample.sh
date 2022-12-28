#!/bin/bash

# A script based upon: https://docs.vmware.com/en/Services-Toolkit-for-VMware-Tanzu-Application-Platform/0.7/svc-tlk/GUID-usecases-consuming_azure_database_with_crossplane.html

# Requirements:

# * az CLI - Provisions cloud resources (i.e., VPC, Azure Postges instances)
# * helm CLI - Deploys Crossplane
# * Tanzu Application Platform (TAP) – Installation of TAP 1.2.x or greater utilizing the
#     “iterate” profile or other profile that has deployed out-of-the-box supply chains,
#     out-of-the-box templates, services toolkit, and service bindings
# * kubectl – You will use this to manage Kubernetes resources
# * Tanzu CLI – You will use this to execute Tanzu specific operations
# * You will need permissive access to the TAP Kubernetes cluster with kubectl and Tanzu CLI tools

APP_NAME="spring-petclinic"
AZURE_SP_NAME='sql-crossplane-demo'
AZURE_SUBSCRIPTION_ID="$( az account show -o json | jq -r '.id' )"
SERVICE_INSTANCE_NAMESPACE="service-instances"
AZURE_RESOURCE_GROUP_NAME="tap-psql-demo"
AZURE_INSTANCE_NAME="azure-postres-db-1"
AZURE_INSTANCE_TYPE="GP_Standard_D2s_v3"
AZURE_POSTGRES_VERSION="12"
AZURE_REGION="westus2"
SERVICE_INSTANCE_NAMESPACE="service-instances"
CROSSPLANE_NAMESPACE="crossplane-system"
CROSSPLANE_PROVIDER_NAME="provider-jet-azure"
CROSSPLANE_PROVIDER_VERSION=v0.12.0 # @see https://github.com/crossplane-contrib/provider-jet-azure/releases for latest available version
CROSSPLANE_PROVIDER_SECRET_NAME="jet-azure-creds"
WORKLOAD_NAMESPACE="workloads"

set -x

# Create namespace to host all service instances
kubectl create ns ${SERVICE_INSTANCE_NAMESPACE}

# Create namespace to host Crossplane
kubectl create ns ${CROSSPLANE_NAMESPACE}

# Install Crossplane
helm repo add crossplane-stable https://charts.crossplane.io/stable
helm repo update
helm install crossplane --namespace ${CROSSPLANE_NAMESPACE} crossplane-stable/crossplane \
  --set 'args={--enable-external-secret-stores}' --wait

# Validate Crossplane was installed
kubectl get pods -n ${CROSSPLANE_NAMESPACE}

# Install Azure provider for Crossplane
kubectl apply -f - <<'EOF'
apiVersion: pkg.crossplane.io/v1alpha1
kind: ControllerConfig
metadata:
  name: jet-azure-config
spec:
  image: crossplane/${CROSSPLANE_PROVIDER_NAME}-controller:${CROSSPLANE_PROVIDER_VERSION}
  args: ["-d"]
---
apiVersion: pkg.crossplane.io/v1
kind: Provider
metadata:
  name: ${CROSSPLANE_PROVIDER_NAME}
spec:
  package: crossplane/${CROSSPLANE_PROVIDER_NAME}:${CROSSPLANE_PROVIDER_VERSION}
  controllerConfigRef:
    name: jet-azure-config
EOF

# Wait for the provider to become healthy
kubectl -n ${CROSSPLANE_NAMESPACE} wait provider/${CROSSPLANE_PROVIDER_NAME} \
  --for=condition=Healthy=True --timeout=3m

# Install the K8s providers for Crossplane
kubectl apply --wait=true -f - <<'EOF'
apiVersion: pkg.crossplane.io/v1
kind: Provider
metadata:
  name: provider-kubernetes
spec:
  package: "crossplane/provider-kubernetes:main"
EOF

# Setup a new Service Principal and create a K8s secret
kubectl create secret generic ${CROSSPLANE_PROVIDER_SECRET_NAME} -o yaml --dry-run=client --from-literal=creds="$(
 az ad sp create-for-rbac -n "${AZURE_SP_NAME}" \
  --sdk-auth \
  --role "Contributor" \
  --scopes "/subscriptions/${AZURE_SUBSCRIPTION_ID}" \
  -o json
)" | kubectl apply -n ${CROSSPLANE_NAMESPACE} -f -

# Configure the Crossplane providers
kubectl apply --wait=true -f - <<'EOF'
---
apiVersion: azure.jet.crossplane.io/v1alpha1
kind: ProviderConfig
metadata:
 name: default
spec:
 credentials:
   source: Secret
   secretRef:
     namespace: ${CROSSPLANE_NAMESPACE}
     name: ${CROSSPLANE_PROVIDER_SECRET_NAME}
     key: creds
EOF

SA=$(kubectl -n crossplane-system get sa -o name | grep provider-kubernetes | sed -e "s|serviceaccount\/|${CROSSPLANE_NAMESPACE}:|g")
kubectl create role -n ${{CROSSPLANE_NAMESPACE} password-manager --resource=passwords.secretgen.k14s.io --verb=create,get,update,delete
kubectl create rolebinding -n ${{CROSSPLANE_NAMESPACE} provider-kubernetes-password-manager --role password-manager --serviceaccount="${SA}"

kubectl apply --wait=true -f - <<'EOF'
apiVersion: kubernetes.crossplane.io/v1alpha1
kind: ProviderConfig
metadata:
  name: default
spec:
  credentials:
    source: InjectedIdentity
EOF


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
kubectl apply --wait=true -f - <<'EOF'
apiVersion: apiextensions.crossplane.io/v1
kind: Composition
metadata:
  labels:
    provider: azure
  name: xpostgresqlinstances.bindable.gcp.database.example.org
spec:
  compositeTypeRef:
    apiVersion: bindable.database.example.org/v1alpha1
    kind: XPostgreSQLInstance
  publishConnectionDetailsWithStoreConfigRef:
    name: default
  resources:
  - name: dbinstance
    base:
      apiVersion: dbforpostgresql.azure.jet.crossplane.io/v1alpha2
      kind: FlexibleServer
      spec:
        forProvider:
          administratorLogin: myPgAdmin
          administratorPasswordSecretRef:
            name: ""
            namespace: ${CROSSPLANE_NAMESPACE}
            key: password
          location: westeurope
          skuName: ${AZURE_INSTANCE_TYPE}
          version: "${AZURE_POSTGRES_VERSION}" #! 11,12 and 13 are supported
          resourceGroupName: ${AZURE_RESOURCE_GROUP_NAME}
        writeConnectionSecretToRef:
          namespace: ${CROSSPLANE_NAMESPACE}
    connectionDetails:
    - name: type
      value: postgresql
    - name: provider
      value: azure
    - name: database
      value: postgres
    - name: username
      fromFieldPath: spec.forProvider.administratorLogin
    - name: password
      fromConnectionSecretKey: "attribute.administrator_password"
    - name: host
      fromFieldPath: status.atProvider.fqdn
    - name: port
      type: FromValue
      value: "5432"
    patches:
    - fromFieldPath: metadata.uid
      toFieldPath: spec.writeConnectionSecretToRef.name
      transforms:
      - string:
          fmt: '%s-postgresql'
          type: Format
        type: string
      type: FromCompositeFieldPath
    - type: FromCompositeFieldPath
      fromFieldPath: metadata.name
      toFieldPath: spec.forProvider.administratorPasswordSecretRef.name
    - fromFieldPath: spec.parameters.storageGB
      toFieldPath: spec.forProvider.storageMb
      type: FromCompositeFieldPath
      transforms:
      - type: math
        math:
          multiply: 1024
  - name: dbfwrule
    base:
      apiVersion: dbforpostgresql.azure.jet.crossplane.io/v1alpha2
      kind: FlexibleServerFirewallRule
      spec:
        forProvider:
          serverIdSelector:
            matchControllerRef: true
          #! not recommended for production deployments!
          startIpAddress: 0.0.0.0
          endIpAddress: 255.255.255.255
  - name: password
    base:
      apiVersion: kubernetes.crossplane.io/v1alpha1
      kind: Object
      spec:
        forProvider:
          manifest:
            apiVersion: secretgen.k14s.io/v1alpha1
            kind: Password
            metadata:
              name: ""
              namespace: ${CROSSPLANE_NAMESPACE}
            spec:
              length: 64
              secretTemplate:
                type: Opaque
                stringData:
                  password: $(value)
    patches:
    - type: FromCompositeFieldPath
      fromFieldPath: metadata.name
      toFieldPath: spec.forProvider.manifest.metadata.name
EOF


# Create a ClusterInstanceClass
kubectl apply --wait=true -f -<<EOF
---
apiVersion: services.apps.tanzu.vmware.com/v1alpha1
kind: ClusterInstanceClass
metadata:
  name: azure-postgres
spec:
  description:
    short: Azure Postgresql database instances
  pool:
    kind: Secret
    labelSelector:
      matchLabels:
        services.apps.tanzu.vmware.com/class: azure-postgres
    fieldSelector: type=connection.crossplane.io/v1alpha1
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

# Provision Azure PostgreSQL instance
kubectl apply --wait=true -f -<<EOF
---
apiVersion: bindable.database.example.org/v1alpha1
kind: PostgreSQLInstance
metadata:
  name: ${AZURE_INSTANCE_NAME}
  namespace: ${SERVICE_INSTANCE_NAMESPACE}
spec:
  parameters:
    #! supported storage sizes: 32, 64, 128, 256, 512, 1024, 2048, 4096, 8192, 16384, 32768
    storageGB: 64
  compositionSelector:
    matchLabels:
      provider: azure
  publishConnectionDetailsTo:
    name: ${AZURE_INSTANCE_NAME}
    metadata:
      labels:
        services.apps.tanzu.vmware.com/class: azure-postgres
EOF

# Verify the Azure database instance was created
az postgres flexible-server list -o table

# Wait for database to be ready for connections
kubectl wait postgresqlinstances.bindable.database.example.org/${AZURE_INSTANCE_NAME} \
  --for=condition=Ready=true --timeout=10m

# Address a bug in Crossplane 1.7.2 onwards with the --enable-external-secret-stores feature gate enabled
# where the controller will fail to clean up a local secret created by the field .spec.publishConnectionDetailsTo
# after the deletion of the claim. A workaround is to temporarily give the crossplane controller the necessary
# i.e. permissions
kubectl create clusterrole crossplane-cleaner --verb=delete --resource=secrets
kubectl create clusterrolebinding crossplane-cleaner --clusterrole=crossplane-cleaner --serviceaccount=${CROSSPLANE_NAMESPACE}:crossplane


# Show available classes of service instances
tanzu service classes list

# Show claimable instances  belonging to the Azure PostgreSQL class
tanzu services claimable list --class azure-postgres

# Create a claim
tanzu service claim create azure-postgres-claim \
  --resource-name ${AWS_RDS_INSTANCE_NAME} \
  --resource-kind Secret \
  --resource-api-version v1

# Obtain the claim reference
tanzu service claim list -o wide

# Create an application workload that consumes the claimed Azure PostgreSQL database. In this example, --service-ref is set to the claim reference obtained earlier.
tanzu apps workload create ${APP_NAME} \
  --namespace ${WORKLOAD_NAMESPACE}
  --git-repo https://github.com/sample-accelerators/spring-petclinic \
  --git-branch main \
  --git-tag tap-1.2 \
  --type web \
  --label app.kubernetes.io/part-of=spring-petclinic \
  --annotation autoscaling.knative.dev/minScale=1 \
  --env SPRING_PROFILES_ACTIVE=postgres \
  --service-ref db=services.apps.tanzu.vmware.com/v1alpha1:ResourceClaim:azure-postgres-claim

set +x

# Follow the build
echo "❯ To check in on status of the deployment, execute: \n\ttanzu apps workloads tail ${APP_NAME} -n ${WORKLOAD_NAMESPACE} --since 10m --timestamp"

# Learn how to engage with app once deployed
echo "❯ To verify that the application has successfully deployed and is running, execute: \n\ttanzu apps workloads get ${APP_NAME} -n ${WORKLOAD_NAMESPACE}"
