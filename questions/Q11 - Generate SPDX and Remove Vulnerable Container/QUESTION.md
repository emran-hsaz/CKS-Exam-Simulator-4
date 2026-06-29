# Generate SPDX Document and Remove Vulnerable Container

## Task
The Deployment `multi-alpine` (namespace `default`) runs three Alpine-based containers,
each on a different Alpine version.

## Requirements

1. Identify which container's image ships the package `libcrypto3` at version `3.1.4-r5` (vulnerable)
2. Remove that container from Deployment `multi-alpine`, leaving the other containers running
3. Using the `bom` tool, generate an SPDX SBOM for that image and save it to `/root/alpine.spdx`

## Step 1 — Check tools are available

```bash
which trivy && trivy --version
which bom   && bom version
```

## Step 2 — Scan each image for the SPECIFIC vulnerable version

```bash
# All alpine images have libcrypto3 — you need the SPECIFIC version 3.1.4-r5
trivy image --scanners vuln alpine:3.18.0 | grep 'libcrypto3'
trivy image --scanners vuln alpine:3.19.1 | grep 'libcrypto3'
trivy image --scanners vuln alpine:3.20.0 | grep 'libcrypto3'
```

Look for the version **`3.1.4-r5`** in the **Installed Version** column.

Expected output for `alpine:3.19.1`:
```
│ libcrypto3 │ CVE-2024-xxxx │ HIGH │ 3.1.4-r5 │ 3.1.4-r6 │ ...
```

> **Answer: `alpine:3.19.1` has libcrypto3 at version `3.1.4-r5` (vulnerable)**
> The other two images have different versions of libcrypto3 that are not `3.1.4-r5`

## Step 3 — Remove the vulnerable container from the Deployment

```bash
kubectl edit deploy multi-alpine
```

Delete the entire `alpine-319` container entry (image: `alpine:3.19.1`).
Leave `alpine-318` and `alpine-320` untouched.

## Step 4 — Generate the SPDX SBOM

```bash
bom generate --image alpine:3.19.1 --output /root/alpine.spdx
```

## Verify

```bash
# Confirm alpine:3.19.1 container is gone
kubectl get deploy multi-alpine \
  -o jsonpath='{.spec.template.spec.containers[*].image}'
# Must show: alpine:3.18.0 alpine:3.20.0

# Confirm SPDX file is non-empty
ls -lh /root/alpine.spdx
```
