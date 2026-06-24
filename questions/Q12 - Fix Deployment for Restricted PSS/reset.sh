#!/bin/bash
kubectl delete deploy pss-app -n restricted-ns --ignore-not-found
kubectl delete namespace restricted-ns --ignore-not-found
echo "Q12 reset done."
