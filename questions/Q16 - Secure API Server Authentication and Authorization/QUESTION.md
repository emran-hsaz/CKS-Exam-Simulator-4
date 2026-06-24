# Secure API Server Authentication and Authorization

## Task
The API server is currently configured insecurely.

## Requirements

1. Disable anonymous access on the API server:
   ```
   --anonymous-auth=false
   ```

2. Configure authorization mode to use:
   ```
   --authorization-mode=Node,RBAC
   ```

3. Enable the `NodeRestriction` admission controller:
   ```
   --enable-admission-plugins=NodeRestriction
   ```

4. Ensure the API server restarts successfully and the cluster remains functional.

## Verify

```bash
kubectl get nodes
kubectl cluster-info
```

> **Warning:** After saving `/etc/kubernetes/manifests/kube-apiserver.yaml`, the API server restarts. Wait up to 60 seconds.
