#!/bin/bash
APISERVER="/etc/kubernetes/manifests/kube-apiserver.yaml"
[ -f "${APISERVER}.bak.q16" ] && cp "${APISERVER}.bak.q16" "$APISERVER" && echo "API server manifest restored."
echo "Q16 reset done."
