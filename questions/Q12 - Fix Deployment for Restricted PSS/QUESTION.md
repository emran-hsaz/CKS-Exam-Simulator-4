# Fix Deployment for Restricted Pod Security Standard

## Task
Namespace `restricted-ns` enforces the `restricted` Pod Security Standard.
A Deployment `pss-app` in this namespace is currently non-compliant and its Pods cannot start.

## Requirements

Update the Deployment so that its Pods comply with the `restricted` Pod Security Standard.
Ensure the Pods run successfully in the restricted namespace.

The `restricted` PSS requires all of the following:

```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  allowPrivilegeEscalation: false
  seccompProfile:
    type: RuntimeDefault
  capabilities:
    drop:
      - ALL
```

## Verify

```bash
kubectl get pods -n restricted-ns
```
