# Generate SPDX Document and Remove Vulnerable Container

## Task
The Deployment `multi-alpine` (namespace `default`) runs three Alpine-based containers,
each on a different Alpine version.

## Requirements

1. Identify which container's image ships the package `libcrypto3-3.1.4-r5`
2. Remove that container from Deployment `multi-alpine`, leaving the other containers running
3. Using the `bom` tool, generate an SPDX SBOM for that image and save it to `/root/alpine.spdx`

## Step 1 — Check tools are available

```bash
which trivy   # should print /usr/bin/trivy
which bom     # should print /usr/local/bin/bom
```

If trivy is missing, install it:
```bash
apt-get update && apt-get install -y trivy
```

If bom is missing, install it:
```bash
wget -qO /usr/local/bin/bom \
  https://github.com/kubernetes-sigs/bom/releases/download/v0.6.0/bom-amd64-linux
chmod +x /usr/local/bin/bom
```

## Step 2 — Scan each image to find libcrypto3-3.1.4-r5

```bash
trivy image alpine:3.18.0 | grep libcrypto3
trivy image alpine:3.19.1 | grep libcrypto3
trivy image alpine:3.20.0 | grep libcrypto3
```

> **Answer: `alpine:3.19.1` contains `libcrypto3-3.1.4-r5`**

## Step 3 — Remove the vulnerable container from the Deployment

```bash
kubectl edit deploy multi-alpine
```

Delete the entire `alpine-319` container block (the one using `alpine:3.19.1`).
Leave `alpine-318` and `alpine-320` untouched.

## Step 4 — Generate the SPDX SBOM

```bash
bom generate --image alpine:3.19.1 --output /root/alpine.spdx
```

## Verify

```bash
# Confirm container is gone
kubectl get deploy multi-alpine \
  -o jsonpath='{.spec.template.spec.containers[*].image}'
# Should show: alpine:3.18.0 alpine:3.20.0 (NOT 3.19.1)

# Confirm SPDX file exists
ls -lh /root/alpine.spdx
```
