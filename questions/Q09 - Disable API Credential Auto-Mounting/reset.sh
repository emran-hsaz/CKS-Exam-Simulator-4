#!/bin/bash
kubectl delete deploy token-app -n default --ignore-not-found
kubectl delete sa app-sa -n default --ignore-not-found
echo "Q9 reset done."
