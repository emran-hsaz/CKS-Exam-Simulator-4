# Create a Restrictive NetworkPolicy

## Task
Namespace `secure-ns` currently allows unrestricted ingress traffic.

## Requirements

1. Create a NetworkPolicy that **denies all ingress traffic by default** in namespace `secure-ns`

2. Create a NetworkPolicy that **allows ingress traffic only from Pods** inside namespace `allowed-ns` labeled `access=granted`

3. Use namespace selectors and pod selectors where required.

4. Verify that traffic from unauthorized namespaces is blocked.

## Verify

```bash
kubectl get networkpolicy -n secure-ns
```
