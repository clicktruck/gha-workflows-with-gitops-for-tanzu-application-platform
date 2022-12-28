#!/bin/bash

# A script based upon: https://tanzu.vmware.com/developer/guides/tanzu-service-secret-sauce/

# Requirements:

# * Tanzu Cluster Essentials (TCE) - This is a prerequisite of Tanzu Application Platform.
#     (Requires TCE 1.2 or greater).
# * Tanzu Application Platform (TAP) – Installation of TAP 1.2.x or greater utilizing the
#     “iterate” profile or other profile that has deployed out-of-the-box supply chains,
#     out-of-the-box templates, services toolkit, and service bindings
# * kubectl – You will use this to manage Kubernetes resources
# * Tanzu CLI – You will use this to execute Tanzu specific operations
# * YTT – You will use this to install a supply chain with user provided values
# * You will need permissive access to the TAP Kubernetes cluster with kubectl and Tanzu CLI tools

APP_NAME="student-redis-sample"
INSTANCE_NAME="redis-test"
OPERATOR_NAME="redis-enterprise-operator"
SERVICE_INSTANCE_NAMESPACE="service-instances"
WORKLOAD_NAMESPACE="workloads"
REDIS_ENTERPRISE_OPERATOR_VERSION="6.2.10-45"

set -x

# Create namespace to host service instances
kubectl create ns ${SERVICE_INSTANCE_NAMESPACE}

# Install Redis Entprise Operator
kubectl apply -f https://raw.githubusercontent.com/RedisLabs/redis-enterprise-k8s-docs/v${REDIS_ENTERPRISE_OPERATOR_VERSION}/bundle.yaml -n ${SERVICE_INSTANCE_NAMESPACE} --wait=true

# Validate operator was installed
kubectl get pods -l name=${OPERATOR_NAME} -n ${SERVICE_INSTANCE_NAMESPACE}

# Use ytt to pass input variable values to templated k8s resource(s) manifest
## Creates Redis resources along with secret template
ytt -f https://raw.githubusercontent.com/gm2552/redis-secret-template/main/templates/redisEnterpriseClusterOperator/redisEnterpriseClusterTemplate.yaml -v service_namespace=${SERVICE_INSTANCE_NAMESPACE} -v instance_name=${INSTANCE_NAME} | kubectl apply --wait=true -f-

# Validate that the cluster has been created and is operational
kubectl get sts ${INSTANCE_NAME}-cluster -n ${SERVICE_INSTANCE_NAMESPACE}

# Validate the SecretTemplate was able to reconcile the Redis configuration into a
# service binding compliant secret
kubectl get secrettemplate ${INSTANCE_NAME}-redis-secret -n ${SERVICE_INSTANCE_NAMESPACE}

# Validate that the service binding compliant secret exists
kubectl get secret ${INSTANCE_NAME}-redis-secret -n ${SERVICE_INSTANCE_NAMESPACE}

# Inspect the aforementioned secret
kubectl describe secret ${INSTANCE_NAME}-redis-secret -n ${SERVICE_INSTANCE_NAMESPACE}

# With the Redis instance running and the service binding compliant secret in place,
# you can view your Redis instance(s) using the tanzu cli “service” plugin. The first step is
# to create a “ClusterInstanceClass” (referred to from this point on as a “service class”)
# which is used to identify and categorize service offerings on a TAP cluster. If you are
# familiar with service “plans” in Cloud Foundry, a service class is a very similar concept.
# Service class definitions are generally created by the service operator role and use
# Kubernetes selectors to find all instances of a given service class on a cluster.
# To create the Redis service class, run
kubectl apply -f https://raw.githubusercontent.com/gm2552/redis-secret-template/main/templates/redisEnterpriseClusterOperator/redisInstanceClasses.yaml --wait=true

# Validate that you can see your new Redis Enterprise Cluster service class
tanzu service class list

# In order for an application on TAP to bind to an instance of a service residing in
# a different namespace, you are required to create “resource claims” (it is recommended even
# if both are in the same namespace). At this point, your Redis instance has not been claimed,
# and you can view the list of all unclaimed service instances in your cluster. Viewing unclaimed
# service instances requires that you specify a service class. To view all the unclaimed instances
# of the Redis service class, run
tanzu service claimable list --class redis-enterprise-cluster -n ${SERVICE_INSTANCE_NAMESPACE}

# Create a claim for your Redis instance and make it available for use by applications
ytt -f https://raw.githubusercontent.com/gm2552/redis-secret-template/main/templates/redisResourceClaimTemplate.yaml -v service_namespace=${SERVICE_INSTANCE_NAMESPACE} -v instance_name=${INSTANCE_NAME} -v workload_namespace=${WORKLOAD_NAMESPACE} | kubectl apply --wait=true -f-

# Verify that your Redis instance has now been claimed
tanzu service claims list -n ${WORKLOAD_NAMESPACE}

# Deploy sample application
ytt -f https://raw.githubusercontent.com/gm2552/redis-secret-template/main/templates/workloadTemplate.yaml -v instance_name=${INSTANCE_NAME} -v workload_namespace=${WORKLOAD_NAMESPACE} | kubectl --wait=true apply -f-

set +x

# Follow the build
echo "❯ To check in on status of the deployment, execute: \n\ttanzu apps workloads tail ${APP_NAME} -n ${WORKLOAD_NAMESPACE} --since 10m --timestamp"

# Learn how to engage with app once deployed
echo "❯ To verify that the application has successfully deployed and is running, execute: \n\ttanzu apps workloads get ${APP_NAME} -n ${WORKLOAD_NAMESPACE}"
