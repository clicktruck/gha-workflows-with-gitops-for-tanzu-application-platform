#!/bin/bash

# A script based upon: https://docs.vmware.com/en/Services-Toolkit-for-VMware-Tanzu-Application-Platform/0.9/svc-tlk/usecases-consuming_aws_rds_with_crossplane.html

# Requirements:

# * aws CLI - Provisions cloud resources (i.e., VPC, RDS instances)
# * helm CLI - Deploys Crossplane
# * Tanzu Application Platform (TAP) – Installation of TAP 1.2.x or greater utilizing the
#     “iterate” profile or other profile that has deployed out-of-the-box supply chains,
#     out-of-the-box templates, services toolkit, and service bindings
# * kubectl – You will use this to manage Kubernetes resources
# * Tanzu CLI – You will use this to execute Tanzu specific operations
# * You will need permissive access to the TAP Kubernetes cluster with kubectl and Tanzu CLI tools

APP_NAME="spring-petclinic"
AWS_PROFILE="default"
AWS_VPC_NAME="service-instances"
SERVICE_INSTANCE_NAMESPACE=${AWS_VPC_NAME}
AWS_RDS_INSTANCE_NAME="rds-postres-db-1"
AWS_RDS_INSTANCE_TYPE="db.t2.micro"
AWS_RDS_POSTGRES_VERSION="12"
AWS_REGION="us-west-2"
SERVICE_INSTANCE_NAMESPACE="service-instances"
CROSSPLANE_NAMESPACE="crossplane-system"
CROSSPLANE_PROVIDER_NAME="crossplane-provider-aws"
CROSSPLANE_PROVIDER_VERSION=v0.36.1 # @see https://github.com/crossplane-contrib/provider-aws/releases for latest available version
CROSSPLANE_PROVIDER_SECRET_NAME="aws-provider-creds"
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

# Install AWS provider for Crossplane
kubectl apply --wait=true -f -<<EOF
---
apiVersion: pkg.crossplane.io/v1
kind: Provider
metadata:
  name: ${CROSSPLANE_PROVIDER_NAME}
spec:
  package: xpkg.upbound.io/crossplane/provider-aws:${CROSSPLANE_PROVIDER_VERSION}
EOF

# See the health of the provider that was just installed
kubectl get provider.pkg.crossplane.io ${CROSSPLANE_PROVIDER_NAME}

# Create a key file with AWS credentials that will be used to create a secret
echo -e "[default]\naws_access_key_id = $(aws configure get aws_access_key_id --profile $AWS_PROFILE)\naws_secret_access_key = $(aws configure get aws_secret_access_key --profile $AWS_PROFILE)\naws_session_token = $(aws configure get aws_session_token --profile $AWS_PROFILE)" > creds.conf
cat creds.conf

# Create secret
kubectl create secret generic ${CROSSPLANE_PROVIDER_SECRET_NAME} -n ${CROSSPLANE_NAMESPACE} --from-file=creds=./creds.conf --wait=true

# Clean-up creds on file-system
rm -f creds.conf

# Configure the Crossplane provider
kubectl apply --wait=true -f -<<EOF
---
apiVersion: aws.crossplane.io/v1beta1
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
    provider: "aws"
    vpc: "${AWS_VPC_NAME}"
  name: xpostgresqlinstances.bindable.aws.database.example.org
spec:
  compositeTypeRef:
    apiVersion: bindable.database.example.org/v1alpha1
    kind: XPostgreSQLInstance
  publishConnectionDetailsWithStoreConfigRef:
    name: default
  resources:
    - name: vpc
      base:
        apiVersion: ec2.aws.crossplane.io/v1beta1
        kind: VPC
        spec:
          forProvider:
            cidrBlock: 192.168.0.0/16
            enableDnsHostNames: true
            enableDnsSupport: true
            region: ${AWS_REGION}
    - name: subnet-a
      base:
        apiVersion: ec2.aws.crossplane.io/v1beta1
        kind: Subnet
        metadata:
          labels:
            zone: ${AWS_REGION}a
        spec:
          forProvider:
            availabilityZone: ${AWS_REGION}a
            cidrBlock: 192.168.64.0/18
            region: ${AWS_REGION}
            vpcIdSelector:
              matchControllerRef: true
    - name: subnet-b
      base:
        apiVersion: ec2.aws.crossplane.io/v1beta1
        kind: Subnet
        metadata:
          labels:
            zone: ${AWS_REGION}b
        spec:
          forProvider:
            availabilityZone: ${AWS_REGION}b
            cidrBlock: 192.168.128.0/18
            region: ${AWS_REGION}
            vpcIdSelector:
              matchControllerRef: true
    - name: subnet-c
      base:
        apiVersion: ec2.aws.crossplane.io/v1beta1
        kind: Subnet
        metadata:
          labels:
            zone: ${AWS_REGION}c
        spec:
          forProvider:
            availabilityZone: ${AWS_REGION}c
            cidrBlock: 192.168.192.0/18
            region: ${AWS_REGION}
            vpcIdSelector:
              matchControllerRef: true
    - name: dbsubnetgroup
      base:
        apiVersion: database.aws.crossplane.io/v1beta1
        kind: DBSubnetGroup
        spec:
          forProvider:
            description: An excellent formation of subnetworks.
            region: ${AWS_REGION}
            subnetIdSelector:
              matchControllerRef: true
    - name: internetgateway
      base:
        apiVersion: ec2.aws.crossplane.io/v1beta1
        kind: InternetGateway
        spec:
          forProvider:
            region: ${AWS_REGION}
            vpcIdSelector:
              matchControllerRef: true
    - name: routetable
      base:
        apiVersion: ec2.aws.crossplane.io/v1beta1
        kind: RouteTable
        spec:
          forProvider:
            associations:
              - subnetIdSelector:
                  matchLabels:
                    zone: ${AWS_REGION}a
              - subnetIdSelector:
                  matchLabels:
                    zone: ${AWS_REGION}b
              - subnetIdSelector:
                  matchLabels:
                    zone: ${AWS_REGION}c
            region: ${AWS_REGION}
            routes:
              - destinationCidrBlock: 0.0.0.0/0
                gatewayIdSelector:
                  matchControllerRef: true
            vpcIdSelector:
              matchControllerRef: true
    - name: securitygroup
      base:
        apiVersion: ec2.aws.crossplane.io/v1beta1
        kind: SecurityGroup
        spec:
          forProvider:
            description: Allow access to PostgreSQL
            groupName: crossplane-getting-started
            ingress:
              - fromPort: 5432
                ipProtocol: tcp
                ipRanges:
                  - cidrIp: 0.0.0.0/0
                    description: Everywhere
                toPort: 5432
            region: ${AWS_REGION}
            vpcIdSelector:
              matchControllerRef: true
    - base:
        apiVersion: database.aws.crossplane.io/v1beta1
        kind: RDSInstance
        spec:
          forProvider:
            dbInstanceClass: ${AWS_RDS_INSTANCE_TYPE}
            engine: postgres
            dbName: postgres
            engineVersion: "${AWS_RDS_POSTGRES_VERSION}"
            masterUsername: masteruser
            publiclyAccessible: true
            region: ${AWS_REGION}
            skipFinalSnapshotBeforeDeletion: true
          writeConnectionSecretToRef:
            namespace: ${CROSSPLANE_NAMESPACE}
      connectionDetails:
        - name: type
          value: postgresql
        - name: provider
          value: aws
        - name: database
          value: postgres
        - fromConnectionSecretKey: username
        - fromConnectionSecretKey: password
        - name: host
          fromConnectionSecretKey: endpoint
        - fromConnectionSecretKey: port
      name: rdsinstance
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
          toFieldPath: spec.forProvider.allocatedStorage
          type: FromCompositeFieldPath
EOF

# Create a ClusterInstanceClass
kubectl apply --wait=true -f -<<EOF
---
apiVersion: services.apps.tanzu.vmware.com/v1alpha1
kind: ClusterInstanceClass
metadata:
  name: rds-postgres
spec:
  description:
    short: AWS RDS Postgresql database instances
  pool:
    kind: Secret
    labelSelector:
      matchLabels:
        services.apps.tanzu.vmware.com/class: rds-postgres
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

# Provision RDS PostgreSQL instance
kubectl apply --wait=true -f -<<EOF
---
apiVersion: bindable.database.example.org/v1alpha1
kind: PostgreSQLInstance
metadata:
  name: ${AWS_RDS_INSTANCE_NAME}
  namespace: ${SERVICE_INSTANCE_NAMESPACE}
spec:
  parameters:
    storageGB: 20
  compositionSelector:
    matchLabels:
      provider: aws
      vpc: ${AWS_VPC_NAME}
  publishConnectionDetailsTo:
    name: ${AWS_RDS_INSTANCE_NAME}
    metadata:
      labels:
        services.apps.tanzu.vmware.com/class: rds-postgres
EOF

# Verify the RDS database instance was created
aws rds describe-db-instances --region ${AWS_REGION} --profile ${AWS_PROFILE}

# Wait for database to be ready for connections
kubectl wait --for=condition=Ready=true postgresqlinstances.bindable.database.example.org ${AWS_RDS_INSTANCE_NAME} \
  --timeout=10m

# Address a bug in Crossplane 1.7.2 onwards with the --enable-external-secret-stores feature gate enabled
# where the controller will fail to clean up a local secret created by the field .spec.publishConnectionDetailsTo
# after the deletion of the claim. A workaround is to temporarily give the crossplane controller the necessary
# i.e. permissions
kubectl create clusterrole crossplane-cleaner --verb=delete --resource=secrets
kubectl create clusterrolebinding crossplane-cleaner --clusterrole=crossplane-cleaner --serviceaccount=${CROSSPLANE_NAMESPACE}:crossplane

# Show available classes of service instances
tanzu service classes list

# Show claimable instances  belonging to the RDS PostgreSQL class
tanzu services claimable list --class rds-postgres

# Create a claim
tanzu service claim create rds-claim \
  --resource-name ${AWS_RDS_INSTANCE_NAME} \
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
  --service-ref db=services.apps.tanzu.vmware.com/v1alpha1:ResourceClaim:rds-claim

set +x

# Follow the build
echo "❯ To check in on status of the deployment, execute: \n\ttanzu apps workloads tail ${APP_NAME} -n ${WORKLOAD_NAMESPACE} --since 10m --timestamp"

# Learn how to engage with app once deployed
echo "❯ To verify that the application has successfully deployed and is running, execute: \n\ttanzu apps workloads get ${APP_NAME} -n ${WORKLOAD_NAMESPACE}"
