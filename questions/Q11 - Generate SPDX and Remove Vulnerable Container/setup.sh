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
  apt-get update -qq 2>/dev/null
  apt-get install -y wget apt-transport-https gnupg 2>/dev/null || true
  wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key \
    | gpg --dearmor -o /usr/share/keyrings/trivy.gpg 2>/dev/null
  echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main" \
    > /etc/apt/sources.list.d/trivy.list
  apt-get update -qq 2>/dev/null
  apt-get install -y trivy 2>/dev/null || true
fi

# --- Install bom if not present ---
if ! command -v bom &>/dev/null; then
  echo "Installing bom..."
  wget -qO /usr/local/bin/bom \
    "https://github.com/kubernetes-sigs/bom/releases/download/v0.6.0/bom-amd64-linux" \
    2>/dev/null && chmod +x /usr/local/bin/bom || true
fi

echo ""
echo "════════════════════════════════════════════════════════"
echo "  Deployment multi-alpine — 3 containers:"
echo ""
echo "    Container      Image            libcrypto3 version"
echo "    ----------     --------         ------------------"
echo "    alpine-318     alpine:3.18.0    3.1.0-r4  (different version)"
echo "    alpine-319     alpine:3.19.1    3.1.4-r5  ← VULNERABLE — this is the target"
echo "    alpine-320     alpine:3.20.0    3.3.x     (patched version)"
echo ""
echo "  All alpine images have libcrypto3 — grep for the SPECIFIC version 3.1.4-r5"
echo ""
echo "  Workflow:"
echo "  1. trivy image --scanners vuln alpine:3.19.1 | grep 'libcrypto3'"
echo "     Look for version 3.1.4-r5 in the Installed Version column"
echo "  2. kubectl edit deploy multi-alpine"
echo "     Delete the alpine-319 container block (image: alpine:3.19.1)"
echo "  3. bom generate --image alpine:3.19.1 --output /root/alpine.spdx"
echo "════════════════════════════════════════════════════════"
echo ""
command -v trivy &>/dev/null && echo "  ✔ trivy installed" || echo "  ✘ trivy NOT installed — install manually"
command -v bom   &>/dev/null && echo "  ✔ bom installed"   || echo "  ✘ bom NOT installed — install manually"
echo ""
