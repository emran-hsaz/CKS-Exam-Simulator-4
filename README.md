# CKS Exam Simulator 4

16 exam-style CKS questions sourced from real exam patterns — different resource names, namespaces, and scenarios from Simulator 1.

> ⚠️ **Requires a real Kubernetes cluster with root access** — use [killercoda.com/playgrounds/scenario/kubernetes](https://killercoda.com/playgrounds/scenario/kubernetes) or the CKS playground.

---

## Quick Start

```bash
git clone https://github.com/emran-hsaz/CKS-Exam-Simulator-4.git
cd CKS-Exam-Simulator-4
chmod +x cks check-all setup-all
```

Set aliases:
```bash
alias k=kubectl
echo 'set expandtab tabstop=2 shiftwidth=2' > ~/.vimrc
```

---

## Workflow

```bash
./cks list           # see all 16 questions and marks
./cks setup 1        # prepare cluster for Q1
./cks q 1            # read the question
                     # ... solve it ...
./cks check 1        # grade your answer
./cks reset 1        # clean up and start over
./setup-all          # set up ALL questions at once
./check-all          # grade ALL questions at once
```

---

## Questions

| # | Topic | Domain | Marks |
|---|---|---|---|
| 1  | Fix Insecure Kubelet and etcd | Cluster Hardening | 4 |
| 2  | Create a TLS Secret | Cluster Hardening | 3 |
| 3  | Dockerfile and Deployment Security | System Hardening | 4 |
| 4  | Detect with Falco and Stop Pod Reading /dev/mem | Runtime Security | 3 |
| 5  | Enforce Container Immutability | System Hardening | 4 |
| 6  | Configure API Server Audit Logging | Cluster Hardening | 4 |
| 7  | Create a Restrictive NetworkPolicy | Microservice Vulnerabilities | 4 |
| 8  | Expose HTTPS Through Ingress with TLS | Cluster Hardening | 4 |
| 9  | Disable API Credential Auto-Mounting | Microservice Vulnerabilities | 4 |
| 10 | Upgrade Worker Node Binary | Cluster Hardening | 4 |
| 11 | Generate SPDX and Remove Vulnerable Container | Supply Chain Security | 3 |
| 12 | Fix Deployment for Restricted PSS | Microservice Vulnerabilities | 5 |
| 13 | Secure the Docker Daemon | System Hardening | 3 |
| 14 | Configure Istio mTLS Authentication | Microservice Vulnerabilities | 4 |
| 15 | Configure ImagePolicyWebhook Admission Control | Supply Chain Security | 4 |
| 16 | Secure API Server Authentication and Authorization | Cluster Hardening | 4 |
| | **Total** | | **61** |

---

## Key Differences from CKS-Exam-Simulator (Simulator 1)

| Q | Simulator 1 | This Simulator (4) |
|---|---|---|
| 2 | ns: tls-demo, secret: tls-web-secret, cert: /root/cks/tls/ | ns: web-app, secret: tls-secret, cert: /root/ |
| 3 | Dockerfile: /root/cks/app/Dockerfile | Dockerfile: /root/Dockerfile |
| 4 | Single suspicious pod in ns suspicious | 3 deployments (nvidia/cpu/gpu) — identify the offender |
| 7 | ns: restricted, label purpose=allowed | ns: secure-ns, label access=granted |
| 8 | host: secure.example.com, secret: https-tls-secret | host: web.example.com, secret: app-tls |
| 9 | mount: /var/run/secrets/tokens | mount: /var/run/secrets/kubernetes.io/serviceaccount |
| 10 | apt-get upgrade (v1.32.0→v1.32.1) | Binary swap (v1.30.0→v1.30.1), staged binary |
| 11 | deploy: alpine-multi | deploy: multi-alpine, package: libcrypto3-3.1.4-r5 |
| 14 | **Cilium** CiliumNetworkPolicy + SPIFFE | **Istio** PeerAuthentication + AuthorizationPolicy |

---

## Companion Repos

| Repo | Questions | Notes |
|---|---|---|
| [CKS-Exam-Simulator](https://github.com/emran-hsaz/CKS-Exam-Simulator) | 16 | Core CKS topics |
| [CKS-Exam-Simulator-2](https://github.com/emran-hsaz/CKS-Exam-Simulator-2) | 9 | AppArmor, Seccomp, gVisor, etcd encryption, kube-bench, OPA |
| [CKS-Exam-Simulator-3](https://github.com/emran-hsaz/CKS-Exam-Simulator-3) | 4 | Real exam twists |
| **CKS-Exam-Simulator-4** | **16** | **Different resource names and scenarios** |

---

## ⚠️ Important Notes

- **Q1, Q6, Q15, Q16** modify `/etc/kubernetes/manifests/kube-apiserver.yaml` or etcd — wait ~60 seconds after saving.
- **Q4** requires Falco DaemonSet running in namespace `falco`. Scale ONLY the offending deployment.
- **Q10** requires SSH access to the worker node.
- **Q11** requires `trivy` and `bom` CLI installed on the node.
- **Q14** requires Istio installed. Resources can still be created for check verification even without Istio.
- Always use `kubectl apply` — never `kubectl replace --force` for Deployments.

---

## CKS Exam Domains

| Domain | Weight |
|---|---|
| Cluster Setup | 10% |
| Cluster Hardening | 15% |
| System Hardening | 15% |
| Minimize Microservice Vulnerabilities | 20% |
| Supply Chain Security | 20% |
| Monitoring, Logging, Runtime Security | 20% |
