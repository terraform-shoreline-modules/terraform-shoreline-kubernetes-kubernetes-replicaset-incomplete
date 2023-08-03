#!/bin/bash

# Set the deployment name and desired number of replicas
deployment_name=$DEPLOYMENT_NAME
desired_replicas="PLACEHOLDER"

# Scale the deployment to the desired number of replicas
kubectl scale deployment "$deployment_name" --replicas="$desired_replicas"