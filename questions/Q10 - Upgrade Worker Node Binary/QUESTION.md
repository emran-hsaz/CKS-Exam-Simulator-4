# Upgrade a Worker Node by One Patch Version

## Task
The worker node is running an older kubelet patch version (`v1.30.0`) and must be upgraded to `v1.30.1`.

## Access

The upgrade is performed on the worker node itself. SSH access is enabled — connect from this node with:

```bash
ssh root@<worker-node>   # password: Kd7wA3fX
```

The target kubelet binary (`v1.30.1`) is already staged on the worker at `/usr/local/bin/kubelet-1.30.1`.

## Requirements

1. Identify the worker node name with `kubectl get nodes`

2. Drain the worker node

3. SSH to the worker, replace the kubelet binary with the staged `v1.30.1` binary, and restart the kubelet

4. Uncordon the node

5. Verify that the worker node is `Ready` and running `v1.30.1`.

## Verify

```bash
kubectl get nodes -o wide
```

> **Note:** After restarting the kubelet, the node may take up to 60 seconds to report the new version and return to Ready.
