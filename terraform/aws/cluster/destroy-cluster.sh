#!/bin/bash

cp destroy/providers.tf .
terraform destroy -auto-approve
rm -Rf .terraform .terraform.lock.hcl terraform.tfstate terraform.tfstate.backup terraform.log terraform.plan
rm -f providers.tf
