#!/bin/bash
kubectl delete deploy secure-app --ignore-not-found
rm -f /root/Dockerfile
echo "Q3 reset done."
