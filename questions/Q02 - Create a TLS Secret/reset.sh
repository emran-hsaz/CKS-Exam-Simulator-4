#!/bin/bash
kubectl delete secret tls-secret -n web-app --ignore-not-found
kubectl delete deploy web-app-deploy -n web-app --ignore-not-found
kubectl delete namespace web-app --ignore-not-found
rm -f /root/tls.crt /root/tls.key
echo "Q2 reset done."
