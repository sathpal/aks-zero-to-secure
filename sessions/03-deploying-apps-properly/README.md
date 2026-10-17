# Session 03: Deploying Applications Properly

**Sat 13 Feb 2027 · 10:00–12:00 IST · live on Microsoft Teams** · recording and slides: see the session pack post in the session channel, or the [YouTube playlist](../../README.md#recordings)

> **Status: outline.** The full step-by-step lab is published here one week before the session. The outcome and topics are fixed; exact commands may change.

| | |
|---|---|
| **Outcome** | Configure the app with ConfigMaps and Secrets, give it probes and resource requests, and roll out and roll back with zero failed requests |
| **Cost** | Course cluster (`./infra/create-cluster.sh`), about US$0.30/hour. Delete it when you finish |
| **Builds on** | Session 2 |

## What you'll learn

- Deployments, ReplicaSets, labels and selectors, and the rolling-update knobs `maxSurge` and `maxUnavailable`.
- ConfigMaps and Secrets. Why a Kubernetes Secret is encoded, not encrypted (Session 9 moves it to Key Vault).
- Startup, readiness and liveness probes. How the app's `/readyz` turns false on shutdown so traffic drains first.
- Resource requests and limits, QoS classes, and what `OOMKilled` means.
- Kustomize: one base, small overlays per environment.

## Agenda

| Time (IST) | Block |
|---|---|
| 10:00 | Recap of last session and your questions (10 min) |
| 10:10 | Concepts (30 min) |
| 10:40 | Live demo and guided lab (50 min) |
| 11:30 | Troubleshooting and Q&A (25 min) |
| 11:55 | Assignment and what's next (5 min) |

## Demo and lab flow

1. Recreate the course cluster and deploy the Session 2 app into `payments`.
2. Move settings into a ConfigMap and a test API key into a Secret; read them as environment variables.
3. Add probes, requests and a memory limit. Watch `kubectl get pods` while a pod starts.
4. Run a request loop during a rollout to 1.1: first without readiness (some requests fail), then with it (none fail).
5. Ship a bad release (`FAIL_READINESS=true`). The rollout stalls, old pods keep serving, then `kubectl rollout undo`.
6. Set a memory limit that is too small and read the `OOMKilled` evidence.
7. Split the manifests into a Kustomize base and `dev` / `prod` overlays.

## How the app grows

The Deployment gains probes, requests and limits, a rollout strategy, a ConfigMap and a Secret, in the shape of [`k8s/base/payments-api`](https://github.com/sathpal/regulated-k8s-reference/blob/main/k8s/base/payments-api/deployment.yaml).

## Reference material

- [regulated-k8s-reference: production operations](https://github.com/sathpal/regulated-k8s-reference/blob/main/aks/07-production.md), sections 5 (requests, limits, QoS), 6 (probes), 9 (rolling update under load) and 10 (bad release rolled back)
- [regulated-k8s-reference: troubleshooting](https://github.com/sathpal/regulated-k8s-reference/blob/main/aks/09-troubleshooting.md), sections 4 (bad config), 5 (OOMKilled) and 7 (readiness on the wrong port)

## Assignment (draft)

Make a rollout that drops requests, then fix it. Post both request-loop outputs and explain the difference.
