#!/bin/bash

terraform init -upgrade
terraform validate
terraform plan -out terraform.plan
terraform apply -auto-approve -state terraform.tfstate terraform.plan
