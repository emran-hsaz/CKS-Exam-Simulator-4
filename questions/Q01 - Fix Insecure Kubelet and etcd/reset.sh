#!/bin/bash
KUBELET_CONFIG="/var/lib/kubelet/config.yaml"
ETCD_MANIFEST="/etc/kubernetes/manifests/etcd.yaml"
[ -f "${KUBELET_CONFIG}.bak.q1" ] && cp "${KUBELET_CONFIG}.bak.q1" "$KUBELET_CONFIG" && echo "Kubelet config restored."
[ -f "${ETCD_MANIFEST}.bak.q1" ] && cp "${ETCD_MANIFEST}.bak.q1" "$ETCD_MANIFEST" && echo "etcd manifest restored."
systemctl restart kubelet 2>/dev/null || true
echo "Q1 reset done."
