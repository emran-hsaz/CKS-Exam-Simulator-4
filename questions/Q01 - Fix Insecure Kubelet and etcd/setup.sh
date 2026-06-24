#!/bin/bash
echo "Setting up Q1 — making kubelet and etcd insecure..."

KUBELET_CONFIG="/var/lib/kubelet/config.yaml"

# --- Kubelet ---
if [ -f "$KUBELET_CONFIG" ]; then
  cp "$KUBELET_CONFIG" "${KUBELET_CONFIG}.bak.q1"
  python3 -c "
import yaml
with open('$KUBELET_CONFIG') as f: c = yaml.safe_load(f)
c.setdefault('authentication',{}).setdefault('anonymous',{})['enabled'] = True
c.setdefault('authorization',{})['mode'] = 'AlwaysAllow'
with open('$KUBELET_CONFIG','w') as f: yaml.dump(c, f, default_flow_style=False)
print('Kubelet made insecure: anonymous=true, mode=AlwaysAllow')
" 2>/dev/null || true
  systemctl restart kubelet 2>/dev/null || true
fi

# --- etcd ---
ETCD_MANIFEST="/etc/kubernetes/manifests/etcd.yaml"
if [ -f "$ETCD_MANIFEST" ]; then
  cp "$ETCD_MANIFEST" "${ETCD_MANIFEST}.bak.q1"
  sed -i 's/--client-cert-auth=true/--client-cert-auth=false/' "$ETCD_MANIFEST" 2>/dev/null || true
  # Add the flag if not present
  grep -q 'client-cert-auth' "$ETCD_MANIFEST" || \
    sed -i '/- etcd$/a\    - --client-cert-auth=false' "$ETCD_MANIFEST" 2>/dev/null || true
  echo "etcd made insecure: --client-cert-auth=false"
fi

echo ""
echo "Done. Fix the kubelet config and etcd manifest to make the cluster secure again."
