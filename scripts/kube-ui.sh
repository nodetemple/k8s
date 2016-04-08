#!/bin/bash
echo "- Setting up Kube UI..."

kubectl create -f - << EOF
kind: List
apiVersion: v1
items:
- kind: ReplicationController
  apiVersion: v1
  metadata:
    name: k8s-dashboard
    namespace: kube-system
    labels:
      app: k8s-dashboard
  spec:
    replicas: 1
    selector:
      app: k8s-dashboard
    template:
      metadata:
        labels:
          app: k8s-dashboard
      spec:
        hostNetwork: false
        restartPolicy: Always
        containers:
        - name: k8s-dashboard
          image: gcr.io/google_containers/kubernetes-dashboard-amd64:canary
          imagePullPolicy: Always
          ports:
          - containerPort: 9090
            protocol: TCP
          args:
          - "--apiserver-host=http://127.0.0.1:8080"
- kind: Service
  apiVersion: v1
  metadata:
    name: dashboard
    namespace: kube-system
    labels:
      app: k8s-dashboard
      kubernetes.io/name: Kube-UI
      kubernetes.io/cluster-service: "true"
  spec:
    selector:
      app: k8s-dashboard
    type: NodePort
    ports:
    - nodePort: 9090
      port: 9090
      targetPort: 9090
      protocol: TCP
- kind: Service
  apiVersion: v1
  metadata:
  name: api
  namespace: default
  labels:
    app: k8s-api
    kubernetes.io/name: Kube-API
    kubernetes.io/cluster-service: "true"
  spec:
  selector:
    app: k8s-api
  ports:
  - port: 9091
    targetPort: 8080
    protocol: TCP
EOF
