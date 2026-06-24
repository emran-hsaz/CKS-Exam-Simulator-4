# Expose HTTPS Through Ingress with TLS Termination

## Task
An application must be exposed over HTTPS using an Ingress.

## Requirements

1. Create an Ingress resource named `web-ingress` with TLS termination using the existing TLS Secret `app-tls`

2. The Ingress must route host `web.example.com` to Service `web-svc` on port `80`

3. Verify that the Ingress terminates TLS for `web.example.com`.

## Verify

```bash
kubectl describe ingress web-ingress
```
