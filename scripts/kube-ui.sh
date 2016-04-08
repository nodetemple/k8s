#!/bin/bash
echo "- Setting up Kube UI..."

kubectl create -f - << EOF
kind: List
apiVersion: v1
items:
- kind: Service
  apiVersion: v1
  metadata:
    name: dashboard
    namespace: default
    labels:
      app: k8s-api
      kubernetes.io/name: Kube-UI
      kubernetes.io/cluster-service: "true"
  spec:
    selector:
      app: k8s-api
    type: NodePort
    ports:
    - nodePort: 9090
      port: 9090
      targetPort: 9090
      protocol: TCP
EOF
