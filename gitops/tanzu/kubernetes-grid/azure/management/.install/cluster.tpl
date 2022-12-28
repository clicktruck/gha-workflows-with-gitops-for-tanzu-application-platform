#! ---------------------------------------------------------------------
#! Basic cluster creation configuration
#! ---------------------------------------------------------------------

CLUSTER_NAME: {{ .cluster_name }}
CLUSTER_PLAN: prod
INFRASTRUCTURE_PROVIDER: azure
# CLUSTER_API_SERVER_PORT:
ENABLE_CEIP_PARTICIPATION: false
ENABLE_AUDIT_LOGGING: false
CLUSTER_CIDR: 100.96.0.0/11
SERVICE_CIDR: 100.64.0.0/13
# CAPBK_BOOTSTRAP_TOKEN_TTL: 30m

#! ---------------------------------------------------------------------
#! Node configuration
#! ---------------------------------------------------------------------

# SIZE:
# CONTROLPLANE_SIZE:
# WORKER_SIZE:
AZURE_CONTROL_PLANE_MACHINE_TYPE: {{ .control_plane_node_machine_type }}
AZURE_NODE_MACHINE_TYPE: {{ .worker_node_machine_type }}
# OS_NAME: ""
# OS_VERSION: ""
# OS_ARCH: ""
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
#! Azure configuration
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
#! Image repository configuration
#! ---------------------------------------------------------------------

# TKG_CUSTOM_IMAGE_REPOSITORY: ""
# TKG_CUSTOM_IMAGE_REPOSITORY_CA_CERTIFICATE: ""

#! ---------------------------------------------------------------------
#! Proxy configuration
#! ---------------------------------------------------------------------

# TKG_HTTP_PROXY: ""
# TKG_HTTPS_PROXY: ""
# TKG_NO_PROXY: ""

#! ---------------------------------------------------------------------
#! Machine Health Check configuration
#! ---------------------------------------------------------------------

ENABLE_MHC: true
# ENABLE_MHC_CONTROL_PLANE: true
# ENABLE_MHC_WORKER_NODE: true
MHC_UNKNOWN_STATUS_TIMEOUT: 5m
MHC_FALSE_STATUS_TIMEOUT: 15m

#! ---------------------------------------------------------------------
#! Identity management configuration
#! ---------------------------------------------------------------------

IDENTITY_MANAGEMENT_TYPE: none

#! Settings for IDENTITY_MANAGEMENT_TYPE: "oidc"
# CERT_DURATION: 2160h
# CERT_RENEW_BEFORE: 360h
# OIDC_IDENTITY_PROVIDER_CLIENT_ID:
# OIDC_IDENTITY_PROVIDER_CLIENT_SECRET:
# OIDC_IDENTITY_PROVIDER_GROUPS_CLAIM: groups
# OIDC_IDENTITY_PROVIDER_ISSUER_URL:
# OIDC_IDENTITY_PROVIDER_SCOPES: "email,profile,groups"
# OIDC_IDENTITY_PROVIDER_USERNAME_CLAIM: email

#! The following two variables are used to configure Pinniped JWTAuthenticator for workload clusters
# SUPERVISOR_ISSUER_URL:
# SUPERVISOR_ISSUER_CA_BUNDLE_DATA:

#! Settings for IDENTITY_MANAGEMENT_TYPE: "ldap"
# LDAP_BIND_DN:
# LDAP_BIND_PASSWORD:
# LDAP_HOST:
# LDAP_USER_SEARCH_BASE_DN:
# LDAP_USER_SEARCH_FILTER:
# LDAP_USER_SEARCH_USERNAME: userPrincipalName
# LDAP_USER_SEARCH_ID_ATTRIBUTE: DN
# LDAP_USER_SEARCH_EMAIL_ATTRIBUTE: DN
# LDAP_USER_SEARCH_NAME_ATTRIBUTE:
# LDAP_GROUP_SEARCH_BASE_DN:
# LDAP_GROUP_SEARCH_FILTER:
# LDAP_GROUP_SEARCH_USER_ATTRIBUTE: DN
# LDAP_GROUP_SEARCH_GROUP_ATTRIBUTE:
# LDAP_GROUP_SEARCH_NAME_ATTRIBUTE: cn
# LDAP_ROOT_CA_DATA_B64:

#! ---------------------------------------------------------------------
#! Antrea CNI configuration
#! ---------------------------------------------------------------------

# ANTREA_NO_SNAT: false
# ANTREA_TRAFFIC_ENCAP_MODE: "encap"
# ANTREA_PROXY: false
# ANTREA_POLICY: true
# ANTREA_TRACEFLOW: false


# KAPP_MANAGED: true
