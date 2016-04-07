#!/bin/bash
echo "- Setting up Kube DNS..."

DNS_HOST=$(echo $DOCKER_HOST | awk -F'[/:]' '{print $4}')
: ${DNS_HOST:=$(ifconfig docker0 | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*')}

kubectl --namespace=kube-system create -f - << EOF
kind: Endpoints
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
    name: dns
EOF

kubectl --namespace=kube-system create -f - << EOF
kind: Service
apiVersion: v1
metadata:
  name: kube-dns
  namespace: kube-system
spec:
  clusterIP: 10.0.0.10
  ports:
  - name: dns
    port: 53
    protocol: UDP
EOF
