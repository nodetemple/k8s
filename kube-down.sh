#!/bin/bash

echo "Starting to teardown Kubernetes..."

echo "- Removing replication controllers, pods, services, endpoints and namespaces..."
kubectl delete --grace-period=1 rc,po,svc,ep,ns --all &>/dev/null

echo "- Removing main Kubernetes containers..."
docker-compose kill &>/dev/null
docker-compose rm -fv &>/dev/null

K8S_CONTAINERS=$(docker ps -a -f "name=k8s_" -q)
echo "- Removing all other containers that were started by Kubernetes..."
docker kill ${K8S_CONTAINERS} &>/dev/null
docker rm -fv ${K8S_CONTAINERS} &>/dev/null

echo "- Removing manifests and other data..."
sudo rm -rf /etc/kubernetes/manifests /var/lib/kubelet

echo "Done: Kubernetes is down."
