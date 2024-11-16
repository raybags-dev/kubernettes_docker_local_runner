#!/bin/bash

# Check system architecture
ARCH=$(uname -m)
OS=$(uname -s | tr '[:upper:]' '[:lower:]')

echo "Detected architecture: $ARCH"
echo "Detected OS: $OS"

# Map architecture to Kind download path
case $ARCH in
    "x86_64")
        KIND_ARCH="amd64"
    ;;
    "aarch64")
        KIND_ARCH="arm64"
    ;;
    "arm64")
        KIND_ARCH="arm64"
    ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
    ;;
esac

# Install Docker if not present
if ! command -v docker &> /dev/null; then
    echo "Docker not found. Installing Docker..."
    sudo apt-get update
    sudo apt-get install -y docker.io
    sudo systemctl start docker
    sudo systemctl enable docker
fi

# Install Kind
echo "Installing Kind for $OS-$KIND_ARCH..."
curl -Lo ./kind "https://kind.sigs.k8s.io/dl/v0.20.0/kind-$OS-$KIND_ARCH"
chmod +x ./kind
sudo mv ./kind /usr/local/bin/

# Verify Kind installation
if ! kind version; then
    echo "Kind installation failed"
    exit 1
fi

# Install kubectl
echo "Installing kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/$OS/$KIND_ARCH/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Create a Kind config file
cat << EOF > kind-config.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
- role: worker
- role: worker
EOF

# Create cluster
echo "Creating Kubernetes cluster..."
kind create cluster --config kind-config.yaml

# Wait for cluster to be ready
echo "Waiting for cluster to be ready..."
sleep 30

# Verify the cluster is running
echo "Verifying cluster status..."
kubectl cluster-info
kubectl get nodes