#!/bin/bash
echo "Setting up Q11 — SPDX and vulnerable container..."

# Deploy multi-alpine with 3 containers
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

# --- Install trivy if not present ---
if ! command -v trivy &>/dev/null; then
  echo "Installing trivy..."
  apt-get update -qq 2>/dev/null && \
  apt-get install -y wget apt-transport-https gnupg 2>/dev/null || true

  wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key \
    | gpg --dearmor -o /usr/share/keyrings/trivy.gpg 2>/dev/null

  echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main" \
    > /etc/apt/sources.list.d/trivy.list

  apt-get update -qq 2>/dev/null && \
  apt-get install -y trivy 2>/dev/null || true
fi

# --- Install bom if not present ---
if ! command -v bom &>/dev/null; then
  echo "Installing bom..."
  BOM_VERSION=$(curl -s https://api.github.com/repos/kubernetes-sigs/bom/releases/latest \
    | grep '"tag_name"' | cut -d'"' -f4 2>/dev/null || echo "v0.6.0")
  wget -qO /usr/local/bin/bom \
    "https://github.com/kubernetes-sigs/bom/releases/download/${BOM_VERSION}/bom-amd64-linux" \
    2>/dev/null && chmod +x /usr/local/bin/bom || true
fi

echo ""
echo "════════════════════════════════════════════════"
echo "  Deployment multi-alpine has 3 containers:"
echo "    - alpine:3.18.0"
echo "    - alpine:3.19.1   ← contains libcrypto3-3.1.4-r5"
echo "    - alpine:3.20.0"
echo ""
echo "  Tools available:"
command -v trivy &>/dev/null && echo "  ✔ trivy:  $(trivy --version 2>/dev/null | head -1)" || echo "  ✘ trivy: not installed (install manually or use the hint above)"
command -v bom   &>/dev/null && echo "  ✔ bom:    $(bom version 2>/dev/null | head -1)"   || echo "  ✘ bom:   not installed"
echo "════════════════════════════════════════════════"
echo ""
echo "Steps:"
echo "  1. trivy image alpine:3.19.1 | grep libcrypto3"
echo "  2. kubectl edit deploy multi-alpine  (remove alpine-319 container)"
echo "  3. bom generate --image alpine:3.19.1 --output /root/alpine.spdx"
