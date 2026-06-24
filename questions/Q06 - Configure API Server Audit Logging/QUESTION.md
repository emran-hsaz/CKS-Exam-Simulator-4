# Configure API Server Audit Logging

## Task
Audit logging is not correctly configured on the API server.

## Requirements

1. Reconfigure the API server to use the provided base audit policy file at `/etc/kubernetes/audit-policy.yaml`

2. Configure audit log retention so that the API server keeps a maximum of **2** audit log files

3. Set the audit log path to `/var/log/kubernetes/audit.log`

4. Verify that the API server starts correctly.

## Key flags to add to kube-apiserver.yaml

```
--audit-policy-file=/etc/kubernetes/audit-policy.yaml
--audit-log-path=/var/log/kubernetes/audit.log
--audit-log-maxbackup=2
```

## Verify

```bash
ls /var/log/kubernetes/audit.log
kubectl get nodes
```

> **Warning:** After saving `/etc/kubernetes/manifests/kube-apiserver.yaml`, the API server restarts. Wait up to 60 seconds.
