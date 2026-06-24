#!/bin/bash
APISERVER="/etc/kubernetes/manifests/kube-apiserver.yaml"
[ -f "${APISERVER}.bak.q15" ] && cp "${APISERVER}.bak.q15" "$APISERVER" && echo "API server manifest restored."
echo "Q15 reset done."
