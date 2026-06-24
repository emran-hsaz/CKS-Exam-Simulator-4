#!/bin/bash
echo "Setting up Q14 — Istio mTLS..."

kubectl create namespace app-ns --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace client-ns --dry-run=client -o yaml | kubectl apply -f -

# Label namespaces for Istio sidecar injection (if Istio is installed)
kubectl label namespace app-ns istio-injection=enabled --overwrite 2>/dev/null || true
kubectl label namespace client-ns istio-injection=enabled --overwrite 2>/dev/null || true

kubectl apply -f - <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: target-app
  namespace: app-ns
spec:
  replicas: 1
  selector:
    matchLabels:
      app: target-app
  template:
    metadata:
      labels:
        app: target-app
    spec:
      containers:
        - name: target
          image: nginx:alpine
          ports:
            - containerPort: 80
            - containerPort: 8080
---
apiVersion: v1
kind: Pod
metadata:
  name: client-pod
  namespace: client-ns
  labels:
    app: client-pod
spec:
  containers:
    - name: client
      image: busybox:latest
      command: ["sh", "-c", "sleep 3600"]
YAML

kubectl rollout status deploy/target-app -n app-ns --timeout=60s 2>/dev/null || true
echo ""
echo "Done."
echo "  Deployment target-app in namespace app-ns (label: app: target-app)"
echo "  Pod client-pod in namespace client-ns"
echo ""
echo "If Istio is not installed, create the resources anyway — the check"
echo "verifies the API objects exist with the correct fields."
