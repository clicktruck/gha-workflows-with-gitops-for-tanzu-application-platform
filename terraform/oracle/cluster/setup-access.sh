#!/usr/bin/env bash

# @see https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengdownloadkubeconfigfile.htm#Setting_Up_Cluster_Access
echo "Setting up access to cluster"
oci ce cluster create-kubeconfig --cluster-id $(terraform output cluster-ocid | tr -d '"') --file $HOME/.kube/config  --region $(terraform output cluster-region | tr -d '"') --token-version 2.0.0
