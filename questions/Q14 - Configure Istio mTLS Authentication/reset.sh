#!/bin/bash
kubectl delete peerauthentication target-mtls -n app-ns --ignore-not-found
kubectl delete authorizationpolicy allow-client -n app-ns --ignore-not-found
kubectl delete deploy target-app -n app-ns --ignore-not-found
kubectl delete pod client-pod -n client-ns --ignore-not-found
kubectl delete namespace app-ns client-ns --ignore-not-found
echo "Q14 reset done."
