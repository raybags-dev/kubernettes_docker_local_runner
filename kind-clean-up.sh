#!/bin/bash

# Delete the Kind cluster
echo "Deleting Kind cluster..."
kind delete cluster

# Stop and remove all Docker containers
echo "Stopping and removing all Docker containers..."
docker stop $(docker ps -aq) 2>/dev/null
docker rm $(docker ps -aq) 2>/dev/null

# Remove all Docker volumes
echo "Removing all Docker volumes..."
docker volume rm $(docker volume ls -q) 2>/dev/null

# Remove Docker Compose services and volumes
echo "Stopping Docker Compose services and removing volumes..."
docker compose down -v 2>/dev/null || echo "No active Docker Compose configuration found."

# Prune unused Docker networks
echo "Pruning unused Docker networks..."
docker network prune -f

# Display remaining Docker resources
echo "Remaining Docker containers:"
docker ps -a

echo "Remaining Docker volumes:"
docker volume ls

echo "Remaining Docker networks:"
docker network ls

# Clean up Kubernetes config
echo "Removing Kubernetes configuration files..."
rm -rf ~/.kube

echo "Cleanup completed successfully!"
