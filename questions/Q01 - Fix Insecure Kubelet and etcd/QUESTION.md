# Fix Insecure Kubelet and etcd

## Task
A cluster node has been configured insecurely.

## Requirements

Ensure the kubelet is configured with:

- `anonymous-auth=false`
- `authorization-mode=Webhook`

Review the etcd static Pod manifest and fix any insecure configuration related to anonymous or unauthenticated access if present.

## Verify

```bash
kubectl get nodes
```

The node must be `Ready` after your changes.

> **Note:** After saving your changes and restarting the kubelet, the node may take up to 60 seconds to return to Ready. If `kubectl get nodes` shows NotReady at first, wait a moment and re-run it.
