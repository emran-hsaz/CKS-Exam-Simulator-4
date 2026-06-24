#!/bin/bash
echo "Setting up Q3 — insecure Dockerfile and Deployment..."

# Create insecure Dockerfile (runs as root, no security context)
cat > /root/Dockerfile << 'DOCKERFILE'
FROM nginx:alpine
RUN echo "app" > /usr/share/nginx/html/index.html
# Missing: USER nobody
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
DOCKERFILE

# Deploy with insecure security context
kubectl apply -f - <<'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: secure-app
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: secure-app
  template:
    metadata:
      labels:
        app: secure-app
    spec:
      containers:
        - name: secure-app
          image: nginx:alpine
          securityContext:
            runAsUser: 0
            readOnlyRootFilesystem: false
            privileged: true
YAML

kubectl rollout status deploy/secure-app --timeout=60s 2>/dev/null || true
echo ""
echo "Done."
echo "  Dockerfile: /root/Dockerfile (missing USER nobody)"
echo "  Deployment secure-app: insecure securityContext — fix it!"
