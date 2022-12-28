#! ---------------------------------------------------------------------
#! Cluster creation basic configuration
#! ---------------------------------------------------------------------

CLUSTER_NAME: {{ .cluster_name }}
CLUSTER_PLAN: prod
NAMESPACE: default
# CLUSTER_API_SERVER_PORT:
CNI: antrea
IDENTITY_MANAGEMENT_TYPE: none

#! ---------------------------------------------------------------------
#! Node configuration
#! ---------------------------------------------------------------------

# SIZE:
# CONTROLPLANE_SIZE:
# WORKER_SIZE:
AZURE_CONTROL_PLANE_MACHINE_TYPE: {{ .control_plane_node_machine_type }}
AZURE_NODE_MACHINE_TYPE: {{ .worker_node_machine_type }}
# CONTROL_PLANE_MACHINE_COUNT: 1
# WORKER_MACHINE_COUNT: 1
# WORKER_MACHINE_COUNT_0:
# WORKER_MACHINE_COUNT_1:
# WORKER_MACHINE_COUNT_2:
# AZURE_CONTROL_PLANE_DATA_DISK_SIZE_GIB : ""
# AZURE_CONTROL_PLANE_OS_DISK_SIZE_GIB : ""
# AZURE_CONTROL_PLANE_MACHINE_TYPE : ""
# AZURE_CONTROL_PLANE_OS_DISK_STORAGE_ACCOUNT_TYPE : ""
# AZURE_ENABLE_NODE_DATA_DISK : ""
# AZURE_NODE_DATA_DISK_SIZE_GIB : ""
# AZURE_NODE_OS_DISK_SIZE_GIB : ""
# AZURE_NODE_MACHINE_TYPE : ""
# AZURE_NODE_OS_DISK_STORAGE_ACCOUNT_TYPE : ""

#! ---------------------------------------------------------------------
#! Azure Configuration
#! ---------------------------------------------------------------------

AZURE_ENVIRONMENT: "AzurePublicCloud"
AZURE_TENANT_ID: {{ .azure_ad_tenant_id }}
AZURE_SUBSCRIPTION_ID: {{ .azure_subscription_id }}
AZURE_CLIENT_ID: {{ .azure_ad_client_id }}
AZURE_CLIENT_SECRET: {{ .azure_ad_client_secret }}
AZURE_LOCATION: {{ .azure_location }}
AZURE_SSH_PUBLIC_KEY_B64: {{ .azure_b64_ssh_public_key }}

AZURE_RESOURCE_GROUP: {{ .azure_resource_group_name }}
AZURE_VNET_RESOURCE_GROUP: {{ .azure_resource_group_name }}
AZURE_VNET_NAME: {{ .azure_virtual_network_name }}
AZURE_VNET_CIDR: 10.1.0.0/16
AZURE_CONTROL_PLANE_SUBNET_NAME: {{ .azure_control_plane_subnet_name }}
AZURE_CONTROL_PLANE_SUBNET_CIDR: 10.1.0.0/24
AZURE_NODE_SUBNET_NAME: {{ .azure_node_subnet_name }}
AZURE_NODE_SUBNET_CIDR: 10.1.1.0/24

# AZURE_CUSTOM_TAGS : ""
# AZURE_ENABLE_PRIVATE_CLUSTER : ""
# AZURE_FRONTEND_PRIVATE_IP : ""
# AZURE_ENABLE_ACCELERATED_NETWORKING : ""

#! ---------------------------------------------------------------------
#! Machine Health Check configuration
#! ---------------------------------------------------------------------

ENABLE_MHC: true
# ENABLE_MHC_CONTROL_PLANE: true
# ENABLE_MHC_WORKER_NODE: true
MHC_UNKNOWN_STATUS_TIMEOUT: 5m
MHC_FALSE_STATUS_TIMEOUT: 15m

#! ---------------------------------------------------------------------
#! Common configuration
#! ---------------------------------------------------------------------

# TKG_CUSTOM_IMAGE_REPOSITORY: ""
# TKG_CUSTOM_IMAGE_REPOSITORY_CA_CERTIFICATE: ""

# TKG_HTTP_PROXY: ""
# TKG_HTTPS_PROXY: ""
# TKG_NO_PROXY: ""

ENABLE_AUDIT_LOGGING: false
ENABLE_DEFAULT_STORAGE_CLASS: true

CLUSTER_CIDR: 100.96.0.0/11
SERVICE_CIDR: 100.64.0.0/13

# OS_NAME: ""
# OS_VERSION: ""
# OS_ARCH: ""

#! ---------------------------------------------------------------------
#! Autoscaler configuration
#! ---------------------------------------------------------------------

ENABLE_AUTOSCALER: true
# AUTOSCALER_MAX_NODES_TOTAL: "0"
# AUTOSCALER_SCALE_DOWN_DELAY_AFTER_ADD: "10m"
# AUTOSCALER_SCALE_DOWN_DELAY_AFTER_DELETE: "10s"
# AUTOSCALER_SCALE_DOWN_DELAY_AFTER_FAILURE: "3m"
# AUTOSCALER_SCALE_DOWN_UNNEEDED_TIME: "10m"
# AUTOSCALER_MAX_NODE_PROVISION_TIME: "15m"
AUTOSCALER_MIN_SIZE_0: 1
AUTOSCALER_MIN_SIZE_1: 1
AUTOSCALER_MIN_SIZE_2: 1
AUTOSCALER_MAX_SIZE_0: 10
AUTOSCALER_MAX_SIZE_1: 10
AUTOSCALER_MAX_SIZE_2: 10

#! ---------------------------------------------------------------------
#! Antrea CNI configuration
#! ---------------------------------------------------------------------

# ANTREA_NO_SNAT: false
# ANTREA_TRAFFIC_ENCAP_MODE: "encap"
# ANTREA_PROXY: false
# ANTREA_POLICY: true
# ANTREA_TRACEFLOW: false


# KAPP_MANAGED: true
