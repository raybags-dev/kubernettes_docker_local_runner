#!/bin/bash

# Ensure the script exits on error
set -e

# Call the cleanup script
echo "Running kind-clean-up.sh to clean up existing resources..."
./kind-clean-up.sh

# Check if the cleanup was successful
if [ $? -eq 0 ]; then
    echo "Cleanup completed successfully."
else
    echo "Cleanup failed. Exiting."
    exit 1
fi

# Call the setup script
echo "Running kind-setup.sh to set up new resources..."
./kind-setup.sh

# Check if the setup was successful
if [ $? -eq 0 ]; then
    echo "Setup completed successfully. Kubernetes cluster is ready."
else
    echo "Setup failed. Exiting."
    exit 1
fi
