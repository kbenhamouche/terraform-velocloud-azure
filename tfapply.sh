#!/bin/bash

# Initialise the configuration
terraform init -input=false

# Plan and deploy
terraform plan -out=tfplan
terraform apply -auto-approve tfplan