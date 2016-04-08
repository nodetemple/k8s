#!/bin/bash
echo "- Setting up Kube DNS..."

DNS_HOST=$(ifconfig docker0 | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*')

kubectl create -f - << EOF
kind: List
apiVersion: v1
items:
- kind: Endpoints
  apiVersion: v1
  metadata:
    name: kube-dns
    namespace: kube-system
  subsets:
  - addresses:
    - ip: ${DNS_HOST}
    ports:
    - port: 53
      protocol: UDP
- kind: Service
  apiVersion: v1
  metadata:
    name: kube-dns
    namespace: kube-system
    labels:
      kubernetes.io/cluster-service: "true"
      kubernetes.io/name: Kube-DNS
  spec:
    clusterIP: 10.0.0.10
    ports:
    - port: 53
      targetPort: 53
      protocol: UDP
EOF
