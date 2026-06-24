#!/bin/bash
kubectl delete deploy multi-alpine -n default --ignore-not-found
rm -f /root/alpine.spdx
echo "Q11 reset done."
