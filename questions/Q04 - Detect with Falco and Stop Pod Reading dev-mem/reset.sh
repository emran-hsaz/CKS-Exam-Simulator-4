#!/bin/bash
kubectl delete deploy nvidia cpu gpu -n default --ignore-not-found
rm -f /etc/falco/rules.d/dev-mem*.yaml /etc/falco/rules.d/q4*.yaml 2>/dev/null || true
echo "Q4 reset done."
