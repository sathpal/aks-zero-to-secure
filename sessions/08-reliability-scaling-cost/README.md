# Session 08: Reliability, Scaling and Cost

**Sat 24 Apr 2027 · 10:00–12:00 IST · live on Microsoft Teams** · recording and slides: see the session pack post in the session channel, or the [YouTube playlist](../../README.md#recordings)

> **Status: outline.** The full step-by-step lab is published here one week before the session. The outcome and topics are fixed; exact commands may change.

| | |
|---|---|
| **Outcome** | Load-test the app, watch pods and nodes scale out and back in, survive a node drain and an upgrade without dropped requests, and read what it cost |
| **Cost** | Higher than usual: 3–4 nodes during the load test, about US$0.50/hour. Delete promptly |
| **Builds on** | Sessions 3 and 7 |

## What you'll learn

- Horizontal Pod Autoscaler on CPU, and event-driven scaling with the KEDA add-on.
- The cluster autoscaler, and node auto-provisioning on AKS Automatic.
- PodDisruptionBudgets, topology spread and availability zones.
- Upgrades: control plane, node image, surge settings and planned maintenance windows.
- Cost levers: right-sized requests, spot node pools, stop/start, and the AKS cost analysis add-on.

## Agenda

| Time (IST) | Block |
|---|---|
| 10:00 | Recap of last session and your questions (10 min) |
| 10:10 | Concepts (30 min) |
| 10:40 | Live demo and guided lab (50 min) |
| 11:30 | Troubleshooting and Q&A (25 min) |
| 11:55 | Assignment and what's next (5 min) |

## Demo and lab flow

1. Add a user node pool across three zones, and spread the app's pods across them.
2. Drain a node under load. With a PodDisruptionBudget, no request fails.
3. Run a k6 load test. The HPA adds pods, then the cluster autoscaler adds a node.
4. Scale on a schedule or a queue with a KEDA ScaledObject, including down to zero.
5. Do a rolling update and a node-image upgrade under load.
6. Read the cost: the cost analysis add-on, plus a spot pool for interruptible work.

## Reference material

- [regulated-k8s-reference: production operations](https://github.com/sathpal/regulated-k8s-reference/blob/main/aks/07-production.md), sections 3 (system and user pools), 4 (zone spread), 7 (drain with a PDB under load), 8 (cluster autoscaler), 9 (rolling update under load) and 11 (HPA)
- [regulated-k8s-reference: HPA](https://github.com/sathpal/regulated-k8s-reference/blob/main/k8s/base/payments-api/hpa.yaml) and [PDB](https://github.com/sathpal/regulated-k8s-reference/blob/main/k8s/base/payments-api/pdb.yaml) manifests
- [arc-aks-automatic-demo](https://github.com/sathpal/arc-aks-automatic-demo): scale from zero on AKS Automatic

## Assignment (draft)

Post your load-test summary and a screenshot of pods and nodes scaling, plus the cost of the hour.
