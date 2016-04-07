#!/bin/bash
echo "- Setting up namespace..."

kubectl create -f - << EOF
kind: Namespace
apiVersion: v1
metadata:
  name: kube-system
  labels:
    name: kube-system
EOF
