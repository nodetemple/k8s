#!/bin/bash
COMPOSE_VERSION=1.6.2
K8S_VERSION=1.2.0

echo "Initializing Kubernetes v${K8S_VERSION} stack..."

if ! [ "$(command -v docker-compose)" ]; then
  echo "- Installing docker-compose..."
  curl -Ls https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-Linux-x86_64 > docker-compose
  chmod +x docker-compose
  sudo mkdir -p /opt/bin
  sudo mv -f docker-compose /opt/bin/docker-compose
fi

if ! [ "$(command -v kubectl)" ]; then
  echo "- Installing kubectl..."
  curl -Ls http://storage.googleapis.com/kubernetes-release/release/v${K8S_VERSION}/bin/linux/amd64/kubectl > kubectl
  chmod +x kubectl
  sudo mkdir -p /opt/bin
  sudo mv -f kubectl /opt/bin/kubectl
fi

echo "- Configuring kubectl..."
kubectl config set-cluster k8s --server=http://127.0.0.1:8080
kubectl config set-context k8s --cluster=k8s
kubectl config use-context k8s

echo "- Enabling Docker engine..."
sudo systemctl enable docker.service
sudo systemctl start docker.service

if ! docker info &>/dev/null; then
  echo "Docker engine is not running. Aborting."
  exit 1
fi

if kubectl cluster-info &>/dev/null; then
  echo "Kubernetes is already running. Aborting."
  exit 1
fi

echo "- Starting main Kubenetes containers..."
docker-compose up -d

echo "- Waiting for Kubernetes stack to become available..."
until kubectl cluster-info &>/dev/null; do
  sleep 1
done

cd scripts
./kube-namespace.sh
./kube-dns.sh
./kube-ui.sh

echo "Kubernetes stack is up."
