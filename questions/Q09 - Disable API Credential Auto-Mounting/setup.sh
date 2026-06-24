#!/bin/bash
echo "Setting up Q9 — Token auto-mounting scenario..."

kubectl create serviceaccount app-sa -n default --dry-run=client -o yaml | kubectl apply -f -

kubectl apply -f - <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: token-app
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: token-app
  template:
    metadata:
      labels:
        app: token-app
    spec:
      serviceAccountName: app-sa
      containers:
        - name: app
          image: busybox:latest
          command: ["sh", "-c", "sleep 3600"]
YAML

kubectl rollout status deploy/token-app --timeout=60s 2>/dev/null || true
echo ""
echo "Done."
echo "  ServiceAccount app-sa is in namespace default (currently auto-mounts tokens)."
echo "  Deployment token-app uses app-sa."
echo "  Task: disable auto-mount on SA, then add projected volume to Deployment."
