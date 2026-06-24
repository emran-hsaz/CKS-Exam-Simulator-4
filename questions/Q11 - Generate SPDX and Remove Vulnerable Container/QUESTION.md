# Generate SPDX Document and Remove Vulnerable Container

## Task
The Deployment `multi-alpine` (namespace `default`) runs three Alpine-based containers, each on a different Alpine version.

## Requirements

1. Identify which container's image ships the package `libcrypto3-3.1.4-r5`

2. Remove that container from the Deployment `multi-alpine`, leaving the other containers running

3. Using the `bom` tool, generate an SPDX SBOM for that image and save it to `/root/alpine.spdx`

## Hint

```bash
trivy image alpine:3.18.0 | grep libcrypto3
trivy image alpine:3.19.1 | grep libcrypto3
trivy image alpine:3.20.0 | grep libcrypto3
```

## Verify

```bash
ls -lh /root/alpine.spdx
kubectl get deploy multi-alpine -o jsonpath='{.spec.template.spec.containers[*].image}'
```
