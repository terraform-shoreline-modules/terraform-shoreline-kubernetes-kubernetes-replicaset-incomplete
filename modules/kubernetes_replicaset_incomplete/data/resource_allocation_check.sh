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