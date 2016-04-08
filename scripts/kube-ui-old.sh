#!/bin/bash
echo "- Setting up Kube UI..."

kubectl --namespace=kube-system create -f - << EOF
kind: ReplicationController
apiVersion: v1
metadata:
  name: kube-ui-v4
  namespace: kube-system
  labels:
    k8s-app: kube-ui
    kubernetes.io/cluster-service: "true"
spec:
  replicas: 1
  selector:
    k8s-app: kube-ui
  template:
    metadata:
      labels:
        k8s-app: kube-ui
        kubernetes.io/cluster-service: "true"
    spec:
      hostNetwork: false
      restartPolicy: Always
      containers:
      - name: kube-ui
        image: gcr.io/google_containers/kube-ui:v4
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 8080
        livenessProbe:
          httpGet:
            path: /
            port: 8080
          initialDelaySeconds: 30
          timeoutSeconds: 5
EOF

kubectl --namespace=kube-system create -f - << EOF
kind: Service
apiVersion: v1
metadata:
  name: kube-ui
  namespace: kube-system
  labels:
    k8s-app: kube-ui
    kubernetes.io/name: Kube-UI
    kubernetes.io/cluster-service: "true"
spec:
  selector:
    k8s-app: kube-ui
  ports:
  - port: 80
    targetPort: 8080
EOF
