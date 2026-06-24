#!/bin/bash
echo "Setting up Q4 — three Deployments, one accessing /dev/mem..."

# Create the three deployments — only 'nvidia' is malicious
for name in cpu gpu; do
  kubectl apply -f - <<YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $name
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: $name
  template:
    metadata:
      labels:
        app: $name
    spec:
      containers:
        - name: $name
          image: busybox:latest
          command: ["sh", "-c", "while true; do echo 'running'; sleep 10; done"]
YAML
done

# The malicious one
kubectl apply -f - <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nvidia
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nvidia
  template:
    metadata:
      labels:
        app: nvidia
    spec:
      containers:
        - name: nvidia
          image: busybox:latest
          command:
            - sh
            - -c
            - |
              while true; do
                cat /dev/mem 2>/dev/null || dd if=/dev/mem bs=1 count=1 2>/dev/null || true
                sleep 5
              done
          securityContext:
            privileged: true
YAML

kubectl rollout status deploy/nvidia --timeout=60s 2>/dev/null || true
kubectl rollout status deploy/cpu --timeout=60s 2>/dev/null || true
kubectl rollout status deploy/gpu --timeout=60s 2>/dev/null || true

echo ""
echo "Done. Three Deployments are running: nvidia, cpu, gpu."
echo "One of them is accessing /dev/mem — use Falco to find out which one."
echo "Falco DaemonSet is in namespace 'falco'."
