#!/bin/bash

echo "Starting to teardown Kubernetes..."

K8S_CONTAINERS=$(docker ps -a -f "name=k8s_" -q)
echo "- Removing all Kubernetes containers..."
docker kill ${K8S_CONTAINERS} &>/dev/null
docker rm -fv ${K8S_CONTAINERS} &>/dev/null

echo "- Removing manifests and other data..."
sudo rm -rf /var/lib/kubelet

echo "Kubernetes is down."
