#!/usr/bin/env bash

# See https://docs.aws.amazon.com/eks/latest/userguide/service_IAM_role.html#create-service-role

aws iam create-role \
  --role-name eksClusterRole \
  --assume-role-policy-document file://"cluster-trust-policy.json"

aws iam attach-role-policy \
  --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy \
  --role-name eksClusterRole

# See https://docs.aws.amazon.com/eks/latest/userguide/create-node-role.html

aws iam create-role \
  --role-name AmazonEKSNodeRole \
  --assume-role-policy-document file://"node-role-trust-relationship.json"

aws iam attach-role-policy \
  --policy-arn arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy \
  --role-name AmazonEKSNodeRole
aws iam attach-role-policy \
  --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly \
  --role-name AmazonEKSNodeRole

aws iam attach-role-policy \
  --policy-arn arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy \
  --role-name AmazonEKSNodeRole

# See https://docs.aws.amazon.com/eks/latest/userguide/connector_IAM_role.html

aws iam create-role \
  --role-name AmazonEKSConnectorAgentRole \
  --assume-role-policy-document file://"eks-connector-agent-trust-policy.json"

aws iam put-role-policy \
  --role-name AmazonEKSConnectorAgentRole \
  --policy-name AmazonEKSConnectorAgentPolicy \
  --policy-document file://"eks-connector-agent-policy.json"