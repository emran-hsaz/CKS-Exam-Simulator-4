# Dockerfile and Deployment Security Best Practices

## Task
An application image is built from an insecure Dockerfile.

## Requirements

Update the Dockerfile at `/root/Dockerfile` to run the container as the `nobody` user:

```dockerfile
USER nobody
```

Update the Deployment `secure-app` security context:

- `runAsUser: 65535`
- `readOnlyRootFilesystem: true`
- `privileged: false`

Verify that the Deployment rolls out successfully.

## Verify

```bash
kubectl rollout status deploy/secure-app
```
