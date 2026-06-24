#!/bin/bash
echo "Setting up Q2 — TLS Secret scenario..."

kubectl create namespace web-app --dry-run=client -o yaml | kubectl apply -f -

mkdir -p /root
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /root/tls.key \
  -out    /root/tls.crt \
  -subj "/CN=web.example.com/O=web-app" 2>/dev/null

kubectl apply -f - <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app-deploy
  namespace: web-app
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
          volumeMounts:
            - name: tls
              mountPath: /etc/tls
              readOnly: true
      volumes:
        - name: tls
          secret:
            secretName: tls-secret
YAML

echo ""
echo "Done."
echo "  Cert: /root/tls.crt"
echo "  Key:  /root/tls.key"
echo "  Deployment web-app-deploy in namespace web-app is failing — Secret tls-secret does not exist."
