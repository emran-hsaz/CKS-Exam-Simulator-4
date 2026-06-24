#!/bin/bash
echo "Setting up Q8 — HTTPS Ingress..."

kubectl apply -f - <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
        - name: web
          image: nginx:alpine
          ports:
            - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: web-svc
  namespace: default
spec:
  selector:
    app: web-app
  ports:
    - port: 80
      targetPort: 80
YAML

# Generate TLS cert and create the secret
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /tmp/web.key \
  -out    /tmp/web.crt \
  -subj "/CN=web.example.com/O=web" 2>/dev/null

kubectl create secret tls app-tls \
  --cert=/tmp/web.crt \
  --key=/tmp/web.key \
  -n default \
  --dry-run=client -o yaml | kubectl apply -f -

rm -f /tmp/web.key /tmp/web.crt
kubectl rollout status deploy/web-app --timeout=60s 2>/dev/null || true

echo ""
echo "Done."
echo "  Service web-svc exists in default namespace on port 80."
echo "  Secret app-tls exists in default namespace (type: kubernetes.io/tls)."
echo "  Create Ingress web-ingress routing web.example.com to web-svc:80 with TLS."
