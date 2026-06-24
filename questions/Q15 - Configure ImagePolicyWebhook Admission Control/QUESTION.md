# Configure ImagePolicyWebhook Admission Control

## Task
The API server must enforce image admission checks using `ImagePolicyWebhook`.

## Requirements

1. Enable the `ImagePolicyWebhook` admission plugin on the API server

2. Use the provided AdmissionConfiguration file at `/etc/kubernetes/admission-config.yaml`

3. Configure ImagePolicyWebhook so that images are denied when the backend is unavailable (`defaultAllow: false`)

4. Restart the API server and verify that the admission configuration is active.

## Key flags to add to kube-apiserver.yaml

```
--enable-admission-plugins=NodeRestriction,ImagePolicyWebhook
--admission-control-config-file=/etc/kubernetes/admission-config.yaml
```

## Verify

```bash
kubectl get pod -n kube-system | grep apiserver
```

> **Warning:** After saving `/etc/kubernetes/manifests/kube-apiserver.yaml`, the API server restarts. Wait up to 60 seconds.
