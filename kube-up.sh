#!/bin/bash
export K8S_VERSION=1.2.2

export SERVICE_IP_RANGE=10.0.0.0/24
export K8S_SERVICE_IP=10.0.0.1
export DNS_SERVICE_IP=10.0.0.10
export DNS_HOST=cluster.local

export PUBLIC_IP=$(awk -F= '/COREOS_PUBLIC_IPV4/ {print $2}' /etc/environment)

echo "Initializing Kubernetes v${K8S_VERSION} stack..."

# TODO: update kubectl if version changed
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

echo "- Starting Docker Engine..."
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
docker run -d --name=k8s_kubelet --net=host --pid=host --privileged \
  --volume=/:/rootfs:ro \
  --volume=/sys:/sys:ro \
  --volume=/dev:/dev \
  --volume=/var/lib/docker/:/var/lib/docker:rw \
  --volume=/var/lib/kubelet/:/var/lib/kubelet:rw \
  --volume=/var/run:/var/run:rw \
  --volume=${PWD}/manifests:/etc/kubernetes/manifests:ro \
  gcr.io/google_containers/hyperkube:v${K8S_VERSION} \
  /hyperkube kubelet \
    --containerized --enable-server --register-node --allow-privileged --config=/etc/kubernetes/manifests \
    --address=127.0.0.1 --hostname-override=${PUBLIC_IP} \
    --cluster-dns=${DNS_SERVICE_IP} --cluster-domain=${DNS_HOST} \
    --read-only-port=0 --cadvisor-port=0

echo "- Waiting for Kubernetes stack to become available..."
until kubectl cluster-info &>/dev/null; do
  sleep 1
done

# TODO: fix access
#kubectl create -f addons

echo "Kubernetes stack is up."
