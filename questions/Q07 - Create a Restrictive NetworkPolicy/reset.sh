#!/bin/bash
kubectl delete networkpolicy --all -n secure-ns --ignore-not-found
kubectl delete deploy protected-app -n secure-ns --ignore-not-found
kubectl delete namespace secure-ns allowed-ns --ignore-not-found
echo "Q7 reset done."
