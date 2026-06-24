# Disable API Credential Auto-Mounting

## Task
A ServiceAccount is automatically mounting API credentials into Pods.

## Requirements

1. Disable automatic token mounting on ServiceAccount `app-sa` in namespace `default`

2. Update Deployment `token-app` to manually mount the ServiceAccount token using a projected volume

3. The token must be mounted as read-only at `/var/run/secrets/kubernetes.io/serviceaccount`

4. Verify that the Pod starts successfully and the token is mounted only through the projected volume.

## Verify

```bash
kubectl get pod -l app=token-app -o yaml | grep -A10 projected
kubectl get deploy token-app
```
