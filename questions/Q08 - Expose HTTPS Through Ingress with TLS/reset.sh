#!/bin/bash
kubectl delete ingress web-ingress -n default --ignore-not-found
kubectl delete svc web-svc -n default --ignore-not-found
kubectl delete deploy web-app -n default --ignore-not-found
kubectl delete secret app-tls -n default --ignore-not-found
echo "Q8 reset done."
