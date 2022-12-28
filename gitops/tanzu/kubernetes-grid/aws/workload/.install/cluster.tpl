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
#! AWS-only MACHINE_TYPE settings override cloud-agnostic SIZE settings.
#! ---------------------------------------------------------------------

# SIZE:
# CONTROLPLANE_SIZE:
# WORKER_SIZE:
CONTROL_PLANE_MACHINE_TYPE: {{ .control_plane_node_machine_type }}
NODE_MACHINE_TYPE: {{ .worker_node_machine_type }}
# CONTROL_PLANE_MACHINE_COUNT: 1
# WORKER_MACHINE_COUNT: 1
# WORKER_MACHINE_COUNT_0:
# WORKER_MACHINE_COUNT_1:
# WORKER_MACHINE_COUNT_2:

#! ---------------------------------------------------------------------
#! AWS Configuration
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

#! For internet-restricted environments, such as airgapped or proxied, you can avoid creating a public-facing load balancer by setting LB scheme to true
# AWS_LOAD_BALANCER_SCHEME_INTERNAL: true

#! ---------------------------------------------------------------------
#! Machine Health Check configuration
#! ---------------------------------------------------------------------

ENABLE_MHC: true
# ENABLE_MHC_CONTROL_PLANE: true
# ENABLE_MHC_WORKER_NODE: true
MHC_UNKNOWN_STATUS_TIMEOUT: 5m
MHC_FALSE_STATUS_TIMEOUT: 12m

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
AUTOSCALER_MIN_SIZE_0: 1
AUTOSCALER_MIN_SIZE_1: 1
AUTOSCALER_MIN_SIZE_2: 1
AUTOSCALER_MAX_SIZE_0: 10
AUTOSCALER_MAX_SIZE_1: 10
AUTOSCALER_MAX_SIZE_2: 10
# AUTOSCALER_MAX_NODES_TOTAL: "0"
# AUTOSCALER_SCALE_DOWN_DELAY_AFTER_ADD: "10m"
# AUTOSCALER_SCALE_DOWN_DELAY_AFTER_DELETE: "10s"
# AUTOSCALER_SCALE_DOWN_DELAY_AFTER_FAILURE: "3m"
# AUTOSCALER_SCALE_DOWN_UNNEEDED_TIME: "10m"
# AUTOSCALER_MAX_NODE_PROVISION_TIME: "15m"

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