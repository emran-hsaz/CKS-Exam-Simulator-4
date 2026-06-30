#!/bin/bash
echo "Setting up Q14 — Istio mTLS..."

# --- Install Istio CRDs if not present (lightweight — just the API types) ---
if ! kubectl get crd peerauthentications.security.istio.io &>/dev/null; then
  echo "Istio CRDs not found — installing..."
  kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.22/manifests/charts/base/crds/crd-all.gen.yaml 2>/dev/null
  echo "Waiting for CRDs to register..."
  sleep 5
fi

if kubectl get crd peerauthentications.security.istio.io &>/dev/null; then
  echo "✔ Istio CRDs are installed (PeerAuthentication, AuthorizationPolicy, etc. available)"
else
  echo "⚠ Could not install Istio CRDs automatically."
  echo "  Install manually with:"
  echo "  kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.22/manifests/charts/base/crds/crd-all.gen.yaml"
fi

kubectl create namespace app-ns --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace client-ns --dry-run=client -o yaml | kubectl apply -f -

# Label namespaces for Istio sidecar injection (no-op if Istio control plane isn't installed,
# but harmless and correct if it is)
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
echo "════════════════════════════════════════════════════════"
echo "  Deployment target-app in namespace app-ns (label: app: target-app)"
echo "  Pod client-pod in namespace client-ns"
echo ""
echo "  NOTE: Only the Istio CRDs were installed (PeerAuthentication,"
echo "  AuthorizationPolicy API types) — NOT the full Istio control plane."
echo "  This is enough to create and validate the resources for this"
echo "  question. Full mTLS enforcement would require the Istio sidecar"
echo "  proxies, which needs the complete control plane (istioctl install)."
echo "════════════════════════════════════════════════════════"
