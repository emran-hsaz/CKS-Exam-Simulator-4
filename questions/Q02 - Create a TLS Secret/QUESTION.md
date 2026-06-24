# Create a TLS Secret

## Task
A Deployment already references a TLS Secret, but the Secret does not exist.

## Requirements

Create the missing TLS Secret named `tls-secret` in namespace `web-app` using the provided certificate and key files:

- Certificate: `/root/tls.crt`
- Key: `/root/tls.key`

The Secret must be of type `kubernetes.io/tls`

Verify that the Deployment Pods start successfully.

## Verify

```bash
kubectl get pods -n web-app
```
