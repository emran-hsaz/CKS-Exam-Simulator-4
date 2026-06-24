#!/bin/bash
echo "Setting up Q11 — SPDX and vulnerable container..."

kubectl apply -f - <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: multi-alpine
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: multi-alpine
  template:
    metadata:
      labels:
        app: multi-alpine
    spec:
      containers:
        - name: alpine-318
          image: alpine:3.18.0
          command: ["sh", "-c", "sleep 3600"]
        - name: alpine-319
          image: alpine:3.19.1
          command: ["sh", "-c", "sleep 3600"]
        - name: alpine-320
          image: alpine:3.20.0
          command: ["sh", "-c", "sleep 3600"]
YAML

kubectl rollout status deploy/multi-alpine --timeout=120s 2>/dev/null || true
echo ""
echo "Done. Deployment multi-alpine has 3 containers:"
echo "  - alpine:3.18.0"
echo "  - alpine:3.19.1   ← contains libcrypto3-3.1.4-r5"
echo "  - alpine:3.20.0"
echo ""
echo "Use trivy to confirm, remove the vulnerable one, then generate SPDX with bom."
