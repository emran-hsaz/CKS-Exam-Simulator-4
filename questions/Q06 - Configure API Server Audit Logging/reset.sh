#!/bin/bash
APISERVER="/etc/kubernetes/manifests/kube-apiserver.yaml"
[ -f "${APISERVER}.bak.q6" ] && cp "${APISERVER}.bak.q6" "$APISERVER" && echo "API server manifest restored."
rm -f /var/log/kubernetes/audit.log
echo "Q6 reset done."
