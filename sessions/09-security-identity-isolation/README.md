# Session 09: AKS Security: Identity and Isolation

**Sat 8 May 2027 · 10:00–12:00 IST · live on Microsoft Teams** · recording and slides: see the session pack post in the session channel, or the [YouTube playlist](../../README.md#recordings)

> **Status: outline.** The full step-by-step lab is published here one week before the session. The outcome and topics are fixed; exact commands may change.

| | |
|---|---|
| **Outcome** | Control who can reach the cluster, let the app read a Key Vault secret with no stored credentials, and allow only the pod traffic it needs |
| **Cost** | Course cluster plus a Key Vault (cents) |
| **Builds on** | Sessions 3, 4 and 6 |

## What you'll learn

- Microsoft Entra ID for cluster sign-in, Azure RBAC for Kubernetes, and why to disable local accounts.
- Namespace-scoped access: a reader who can see `payments` and nothing else.
- **Workload identity**: a Kubernetes service account federated to a managed identity, so no secret is stored anywhere.
- Key Vault with the Secrets Store CSI driver, which replaces the Session 3 Kubernetes Secret.
- Network policies enforced by Cilium: default deny, then allow only what's needed.
- Reaching the API server: authorized IP ranges and private clusters. What a pod can read from the instance metadata service.
- Pod Security Standards (`restricted`): non-root, read-only filesystem, no added capabilities.

## Agenda

| Time (IST) | Block |
|---|---|
| 10:00 | Recap of last session and your questions (10 min) |
| 10:10 | Concepts (30 min) |
| 10:40 | Live demo and guided lab (50 min) |
| 11:30 | Troubleshooting and Q&A (25 min) |
| 11:55 | Assignment and what's next (5 min) |

## Demo and lab flow

1. Enable Entra ID and Azure RBAC on the course cluster, then disable local accounts.
2. Grant a namespace-only reader role, and prove it with that user's real token.
3. Create a managed identity, federate it with the app's service account, and read a Key Vault secret.
4. Apply default-deny network policies, then allow only gateway → app and app → DNS.
5. Show what a pod can learn from IMDS, and block it.
6. Label the namespace for Pod Security `restricted`, and watch a root pod get refused.

## How the app grows

The app runs with a dedicated service account, a restricted security context and least-privilege network policy, and reads its secret from Key Vault.

## Reference material

- [regulated-k8s-reference: security](https://github.com/sathpal/regulated-k8s-reference/blob/main/aks/08-security.md), sections 1–6 (Entra ID and Azure RBAC, namespace reader, workload identity with Key Vault, Pod Security, Cilium network policy)
- [regulated-k8s-reference: VMs and AKS nodes](https://github.com/sathpal/regulated-k8s-reference/blob/main/aks/03-vms-and-aks-nodes.md), sections 6–8 (IMDS and the node's identities)

## Assignment (draft)

Post proof that the app reads its secret with no Kubernetes Secret object, plus a request that your network policy blocked.
