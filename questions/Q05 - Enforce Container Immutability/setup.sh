#!/bin/bash
echo "Setting up Q5 — mutable-app Deployment..."

kubectl apply -f - <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mutable-app
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mutable-app
  template:
    metadata:
      labels:
        app: mutable-app
    spec:
      containers:
        - name: mutable-app
          image: nginx:alpine
          securityContext:
            runAsUser: 0
            readOnlyRootFilesystem: false
            allowPrivilegeEscalation: true
YAML

kubectl rollout status deploy/mutable-app --timeout=60s 2>/dev/null || true
echo "Done. Deployment mutable-app is running with insecure securityContext — fix it."
