# Enforce Container Immutability

## Task
A Deployment is running with an insecure container security context.

## Requirements

Update the container security context of Deployment `mutable-app` to enforce immutability:

- `runAsUser: 30000`
- `readOnlyRootFilesystem: true`
- `allowPrivilegeEscalation: false`

## Verify

```bash
kubectl get deploy mutable-app
```

Verify that the Deployment is available.
