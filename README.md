
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Kubernetes Replicaset Incomplete
---

A Kubernetes Replicaset Incomplete incident typically occurs when a specific number of pods that should be running are not, due to reasons such as failed pod initialization, unavailability of resources in the cluster, or inability to pull the image. This incident is usually triggered when the difference between desired and running pods is greater than zero, and it can be detected through monitoring tools like Datadog.

### Parameters
```shell
# Environment Variables

export DEPLOYMENT_NAME="PLACEHOLDER"

export REPLICA_SET_NAME="PLACEHOLDER"

```

## Debug

### List all the deployments in the current namespace
```shell
kubectl get deployments
```

### Check the status of a specific deployment
```shell
kubectl describe deployment ${DEPLOYMENT_NAME}
```

### List all the replica sets in the current namespace
```shell
kubectl get rs
```

### Check the status of a specific replica set
```shell
kubectl describe rs ${REPLICA_SET_NAME}
```

### List all the events in the current namespace
```shell
kubectl get events
```
### Insufficient resources in the cluster, such as insufficient memory or CPU, can cause pods to fail to initialize or start.
```shell
#!/bin/bash

# 1. Get the list of nodes in the cluster

nodes=$(kubectl get nodes -ojsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}')

# 2. Loop through the nodes and check their resource allocation

for node in $nodes; do

  # Get the CPU and memory limits for the node

  cpu_limit=$(kubectl describe node $node | awk '/cpu:/ {print $3}')

  memory_limit=$(kubectl describe node $node | awk '/memory:/ {print $3}')

  # Get the total CPU and memory available for the node

  cpu_available=$(kubectl describe node $node | awk '/Allocatable.*cpu/ {print $2}')

  memory_available=$(kubectl describe node $node | awk '/Allocatable.*memory/ {print $2}')

  # Calculate the percentage of CPU and memory being used

  cpu_percent=$(echo "scale=2; (1 - ($cpu_available/$cpu_limit)) * 100" | bc)

  memory_percent=$(echo "scale=2; (1 - ($memory_available/$memory_limit)) * 100" | bc)

  # Check if the percentage of CPU or memory being used is too high

  if (( $(echo "$cpu_percent > 90" | bc -l) )) || (( $(echo "$memory_percent > 90" | bc -l) )); then

    echo "Node $node is running out of resources."

  fi

done
```
### Incorrect configuration of the Kubernetes Replicaset and its associated pods can cause the desired number of pods to be different from the actual number of running pods.
```shell
bash
#!/bin/bash
# Define the name of the replicaset to check

REPLICASET_NAME=${REPLICA_SET_NAME}

# Get the number of desired replicas for the replicaset

DESIRED_REPLICAS=$(kubectl get replicaset $REPLICASET_NAME -o=jsonpath='{.spec.replicas}')

# Get the number of current replicas for the replicaset

CURRENT_REPLICAS=$(kubectl get replicaset $REPLICASET_NAME -o=jsonpath='{.status.replicas}')

# Compare the number of desired and current replicas

if [ "$DESIRED_REPLICAS" -ne "$CURRENT_REPLICAS" ]; then

  echo "There is a mismatch between the desired ($DESIRED_REPLICAS) and current ($CURRENT_REPLICAS) number of replicas for the $REPLICASET_NAME replicaset."

  # Additional actions to take in case of a mismatch

else

  echo "The desired and current number of replicas for the $REPLICASET_NAME replicaset match."

fi

```

## Repair
### Adjusts the number of replicas in a deployment.
```shell
#!/bin/bash

# Set the deployment name and desired number of replicas
deployment_name=$DEPLOYMENT_NAME
desired_replicas="PLACEHOLDER"

# Scale the deployment to the desired number of replicas
kubectl scale deployment "$deployment_name" --replicas="$desired_replicas"

```
### Rolling restart deployment.
```shell
kubectl rollout restart deployment $DEPLOYMENT_NAME

```