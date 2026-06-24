#!/bin/bash
echo "Setting up Q7 — NetworkPolicy scenario..."

kubectl create namespace secure-ns --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace allowed-ns --dry-run=client -o yaml | kubectl apply -f -
kubectl label namespace allowed-ns access=granted --overwrite

kubectl apply -f - <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: protected-app
  namespace: secure-ns
spec:
  replicas: 1
  selector:
    matchLabels:
      app: protected-app
  template:
    metadata:
      labels:
        app: protected-app
    spec:
      containers:
        - name: nginx
          image: nginx:alpine
          ports:
            - containerPort: 80
YAML

kubectl rollout status deploy/protected-app -n secure-ns --timeout=60s 2>/dev/null || true
echo "Done."
echo "  Namespace secure-ns has Deployment protected-app with no NetworkPolicy."
echo "  Namespace allowed-ns is labeled access=granted."
echo "  Create a NetworkPolicy in secure-ns that denies all ingress except from allowed-ns."
