#!/bin/bash
echo "Setting up Q6 — Audit Logging..."

APISERVER="/etc/kubernetes/manifests/kube-apiserver.yaml"

# Create the audit policy file
mkdir -p /etc/kubernetes
cat > /etc/kubernetes/audit-policy.yaml << 'POLICY'
apiVersion: audit.k8s.io/v1
kind: Policy
rules:
  - level: Metadata
    resources:
      - group: ""
        resources: ["secrets", "configmaps"]
  - level: RequestResponse
    verbs: ["delete"]
    resources:
      - group: ""
        resources: ["pods"]
  - level: None
    users: ["system:kube-proxy"]
  - level: Metadata
POLICY

# Create log directory
mkdir -p /var/log/kubernetes

# Remove audit flags if already present (ensure clean state)
if [ -f "$APISERVER" ]; then
  cp "$APISERVER" "${APISERVER}.bak.q6"
  sed -i '/audit-policy-file/d;/audit-log-path/d;/audit-log-maxbackup/d;/audit-log-maxage/d;/audit-log-maxsize/d' "$APISERVER"
fi

echo "Done."
echo "  Audit policy: /etc/kubernetes/audit-policy.yaml"
echo "  Log directory: /var/log/kubernetes/"
echo "  Edit /etc/kubernetes/manifests/kube-apiserver.yaml to enable audit logging."
