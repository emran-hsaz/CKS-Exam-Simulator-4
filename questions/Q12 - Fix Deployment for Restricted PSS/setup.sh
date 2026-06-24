#!/bin/bash
echo "Setting up Q12 — Restricted PSS namespace..."

kubectl create namespace restricted-ns --dry-run=client -o yaml | kubectl apply -f -

# Enforce restricted PSS on the namespace
kubectl label namespace restricted-ns \
  pod-security.kubernetes.io/enforce=restricted \
  pod-security.kubernetes.io/enforce-version=latest \
  --overwrite

# Deploy non-compliant app (Pods will be blocked by PSS)
kubectl apply -f - <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: pss-app
  namespace: restricted-ns
spec:
  replicas: 1
  selector:
    matchLabels:
      app: pss-app
  template:
    metadata:
      labels:
        app: pss-app
    spec:
      containers:
        - name: pss-app
          image: nginx:alpine
          securityContext:
            privileged: true
            runAsUser: 0
YAML

echo ""
echo "Done."
echo "  Namespace restricted-ns enforces the restricted PSS."
echo "  Deployment pss-app has non-compliant securityContext — Pods are blocked."
echo "  Fix the Deployment securityContext to make it compliant."
