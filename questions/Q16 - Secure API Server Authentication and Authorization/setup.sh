#!/bin/bash
echo "Setting up Q16 — insecure API server configuration..."

APISERVER="/etc/kubernetes/manifests/kube-apiserver.yaml"
if [ -f "$APISERVER" ]; then
  cp "$APISERVER" "${APISERVER}.bak.q16"

  # Make it insecure
  sed -i 's/--anonymous-auth=false/--anonymous-auth=true/' "$APISERVER" 2>/dev/null || true
  sed -i 's/--authorization-mode=Node,RBAC/--authorization-mode=AlwaysAllow/' "$APISERVER" 2>/dev/null || true

  # Add anonymous-auth=true if not present
  grep -q 'anonymous-auth' "$APISERVER" || \
    sed -i '/- kube-apiserver/a\    - --anonymous-auth=true' "$APISERVER" 2>/dev/null || true

  echo "API server made insecure: anonymous-auth=true, authorization-mode=AlwaysAllow"
fi

echo ""
echo "Done. Fix these flags in /etc/kubernetes/manifests/kube-apiserver.yaml:"
echo "  --anonymous-auth=false"
echo "  --authorization-mode=Node,RBAC"
echo "  --enable-admission-plugins=NodeRestriction"
