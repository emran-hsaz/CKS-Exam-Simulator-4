# Detect with Falco and Stop the Pod Reading /dev/mem

## Context

Three Deployments (`nvidia`, `cpu` and `gpu`) run in the `default` namespace, all built from the same image. One of them runs a process that reads the physical-memory device `/dev/mem`, which is a serious security concern. Falco is already running on this node as a DaemonSet (namespace `falco`).

## Requirements

1. Create a Falco rule that detects any process opening `/dev/mem`. Put it on this node under `/etc/falco/rules.d/` (a `.yaml` file) and make sure Falco loads it.

2. Use Falco's output to work out which Deployment's Pod accesses `/dev/mem`.

3. Scale **only that Deployment** down to 0 replicas. Leave the other two running. When you are done, no Pods of the offending Deployment should remain.

## Verify

```bash
kubectl get deploy -n default
# The offending deployment must show 0/0 READY
# The other two must still be running
```
