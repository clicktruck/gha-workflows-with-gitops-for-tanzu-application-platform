#! ---------------------------------------------------------------------
#! Basic cluster creation configuration
#! ---------------------------------------------------------------------

NAMESPACE: tkg-system

CLUSTER_NAME: {{ .cluster_name }}
CLUSTER_PLAN: prod
INFRASTRUCTURE_PROVIDER: aws
# CLUSTER_API_SERVER_PORT:
ENABLE_CEIP_PARTICIPATION: false
ENABLE_AUDIT_LOGGING: false
CLUSTER_CIDR: 100.96.0.0/11
SERVICE_CIDR: 100.64.0.0/13
# CAPBK_BOOTSTRAP_TOKEN_TTL: 30m

#! ---------------------------------------------------------------------
#! Node configuration
#! AWS-only MACHINE_TYPE settings override cloud-agnostic SIZE settings.
#! ---------------------------------------------------------------------

# SIZE:
# CONTROLPLANE_SIZE:
# WORKER_SIZE:
CONTROL_PLANE_MACHINE_TYPE: {{ .control_plane_node_machine_type }}
NODE_MACHINE_TYPE: {{ .worker_node_machine_type }}
# OS_NAME: ""
# OS_VERSION: ""
# OS_ARCH: ""

#! ---------------------------------------------------------------------
#! AWS configuration
#! ---------------------------------------------------------------------

AWS_REGION: {{ .aws_region }}
# Obtained w/: aws ec2 describe-subnets --region {region} --filter Name=vpc-id,Values={vpc-id} --query 'Subnets[?MapPublicIpOnLaunch==`false`].AvailabilityZone' | sed -n '2p' | tr -d '"' | tr -d ',' | awk '{gsub(/^ +| +$/,"")} {print $0}'
AWS_NODE_AZ: {{ .aws_node_az1 }}
# Obtained w/: aws ec2 describe-subnets --region {region} --filter Name=vpc-id,Values={vpc-id} --query 'Subnets[?MapPublicIpOnLaunch==`false`].AvailabilityZone' | sed -n '3p' | tr -d '"' | tr -d ',' | awk '{gsub(/^ +| +$/,"")} {print $0}'
AWS_NODE_AZ_1: {{ .aws_node_az2 }}
# Obtained w/: aws ec2 describe-subnets --region {region} --filter Name=vpc-id,Values={vpc-id} --query 'Subnets[?MapPublicIpOnLaunch==`false`].AvailabilityZone' | sed -n '4p' | tr -d '"' | tr -d ',' | awk '{gsub(/^ +| +$/,"")} {print $0}'
AWS_NODE_AZ_2: {{ .aws_node_az3 }}
AWS_SSH_KEY_NAME: {{ .aws_ssh_keypair_name }}

# AWS_ACCESS_KEY_ID:
# AWS_SECRET_ACCESS_KEY:

BASTION_HOST_ENABLED: false

AWS_VPC_ID: {{ .aws_vpc_id }}
# Obtained w/: aws ec2 describe-subnets --region {region} --filter Name=vpc-id,Values={vpc-id} --query 'Subnets[?MapPublicIpOnLaunch==`true`].SubnetId' | sed -n '2p' | tr -d '"' | tr -d ',' | awk '{gsub(/^ +| +$/,"")} {print $0}'
AWS_PUBLIC_SUBNET_ID: {{ aws_public_subnet_id }}
# Obtained w/: aws ec2 describe-subnets --region {region} --filter Name=vpc-id,Values={vpc-id} --query 'Subnets[?MapPublicIpOnLaunch==`false`].SubnetId' | sed -n '2p' | tr -d '"' | tr -d ',' | awk '{gsub(/^ +| +$/,"")} {print $0}'
AWS_PRIVATE_SUBNET_ID: {{ .aws_private_subnet_id }}
# Obtained w/: aws ec2 describe-subnets --region {region} --filter Name=vpc-id,Values={vpc-id} --query 'Subnets[?MapPublicIpOnLaunch==`true`].SubnetId' | sed -n '3p' | tr -d '"' | tr -d ',' | awk '{gsub(/^ +| +$/,"")} {print $0}'
AWS_PUBLIC_SUBNET_ID_1: {{ aws_public_subnet_id_1 }}
# Obtained w/: aws ec2 describe-subnets --region {region} --filter Name=vpc-id,Values={vpc-id} --query 'Subnets[?MapPublicIpOnLaunch==`false`].SubnetId' | sed -n '3p' | tr -d '"' | tr -d ',' | awk '{gsub(/^ +| +$/,"")} {print $0}'
AWS_PRIVATE_SUBNET_ID_1: {{ .aws_private_subnet_id_1 }}
# Obtained w/: aws ec2 describe-subnets --region {region} --filter Name=vpc-id,Values={vpc-id} --query 'Subnets[?MapPublicIpOnLaunch==`true`].SubnetId' | sed -n '4p' | tr -d '"' | tr -d ',' | awk '{gsub(/^ +| +$/,"")} {print $0}'
AWS_PUBLIC_SUBNET_ID_2: {{ .aws_public_subnet_id_2 }}
# Obtained w/: aws ec2 describe-subnets --region {region} --filter Name=vpc-id,Values={vpc-id} --query 'Subnets[?MapPublicIpOnLaunch==`false`].SubnetId' | sed -n '4p' | tr -d '"' | tr -d ',' | awk '{gsub(/^ +| +$/,"")} {print $0}'
AWS_PRIVATE_SUBNET_ID_2: {{ .aws_private_subnet_id_2 }}

# Obtained w/: aws ec2 describe-vpcs --region {region} --vpc-ids {vpc-id} --query 'Vpcs[*].CidrBlock' | sed -n '2p' | tr -d '"' | awk '{gsub(/^ +| +$/,"")} {print $0}'
AWS_VPC_CIDR: {{ .aws_vpc_cidr }}
# Obtained w/: aws ec2 describe-subnets --region {region} --filter Name=vpc-id,Values={vpc-id} --query 'Subnets[?MapPublicIpOnLaunch==`false`].CidrBlock' | sed -n '2p' | tr -d '"' | tr -d ',' | awk '{gsub(/^ +| +$/,"")} {print $0}'
AWS_PRIVATE_NODE_CIDR: {{ aws_private_node_cidr }}
# Obtained w/: aws ec2 describe-subnets --region {region} --filter Name=vpc-id,Values={vpc-id} --query 'Subnets[?MapPublicIpOnLaunch==`false`].CidrBlock' | sed -n '3p' | tr -d '"' | tr -d ',' | awk '{gsub(/^ +| +$/,"")} {print $0}'
AWS_PRIVATE_NODE_CIDR_1: {{ aws_private_node_cidr_1 }}
# Obtained w/: aws ec2 describe-subnets --region {region} --filter Name=vpc-id,Values={vpc-id} --query 'Subnets[?MapPublicIpOnLaunch==`false`].CidrBlock' | sed -n '4p' | tr -d '"' | tr -d ',' | awk '{gsub(/^ +| +$/,"")} {print $0}'
AWS_PRIVATE_NODE_CIDR_2: {{ aws_private_node_cidr_2 }}
# Obtained w/: aws ec2 describe-subnets --region {region} --filter Name=vpc-id,Values={vpc-id} --query 'Subnets[?MapPublicIpOnLaunch==`true`].CidrBlock' | sed -n '2p' | tr -d '"' | tr -d ',' | awk '{gsub(/^ +| +$/,"")} {print $0}'
AWS_PUBLIC_NODE_CIDR: {{ aws_public_node_cidr }}
# Obtained w/: aws ec2 describe-subnets --region {region} --filter Name=vpc-id,Values={vpc-id} --query 'Subnets[?MapPublicIpOnLaunch==`true`].CidrBlock' | sed -n '3p' | tr -d '"' | tr -d ',' | awk '{gsub(/^ +| +$/,"")} {print $0}'
AWS_PUBLIC_NODE_CIDR_1: {{ aws_public_node_cidr_1 }}
# Obtained w/: aws ec2 describe-subnets --region {region} --filter Name=vpc-id,Values={vpc-id} --query 'Subnets[?MapPublicIpOnLaunch==`true`].CidrBlock' | sed -n '4p' | tr -d '"' | tr -d ',' | awk '{gsub(/^ +| +$/,"")} {print $0}'
AWS_PUBLIC_NODE_CIDR_2: {{ aws_public_node_cidr_2 }}

#! Uncomment this section if you previously created the security groups and security group rules
#! @see https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.5/vmware-tanzu-kubernetes-grid-15/GUID-mgmt-clusters-config-aws.html#use-an-existing-vpc-with-custom-security-groups-6
#! If this section remains commented then you may fetch security group ids by querying AWS Cluster API > NetworkStatus, see https://cluster-api-aws.sigs.k8s.io/crd/index.html#infrastructure.cluster.x-k8s.io/v1alpha4.AWSClusterStatus
# AWS_SECURITY_GROUP_BASTION: {{ .aws_bastion_security_group }}
# AWS_SECURITY_GROUP_CONTROLPLANE: {{ .aws_controlplane_security_group }}
# AWS_SECURITY_GROUP_APISERVER_LB: {{ .aws_apiserver_security_group }}
# AWS_SECURITY_GROUP_NODE: {{ .aws_node_security_group }}
# AWS_SECURITY_GROUP_LB: {{ .aws_lb_security_group }}

#! For internet-restricted environments, such as airgapped or proxied, you can avoid creating a public-facing load balancer by setting LB scheme to true
# AWS_LOAD_BALANCER_SCHEME_INTERNAL: true

#! Disables IAM permissions required for TMC enablement
# DISABLE_TMC_CLOUD_PERMISSIONS: false

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
MHC_FALSE_STATUS_TIMEOUT: 12m

#! ---------------------------------------------------------------------
#! Identity management configuration
#! ---------------------------------------------------------------------

IDENTITY_MANAGEMENT_TYPE: "none"

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

#! Manage with kapp?
#! @see https://github.com/warroyo/future-blog/tree/main/TKG/kapp-managed-clusters
KAPP_MANAGED: true