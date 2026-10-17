# Session 04: AKS Networking Explained

**Sat 27 Feb 2027 · 10:00–12:00 IST · live on Microsoft Teams** · recording and slides: see the session pack post in the session channel, or the [YouTube playlist](../../README.md#recordings)

> **Status: outline.** The full step-by-step lab is published here one week before the session. The outcome and topics are fixed; exact commands may change.

<!-- instructor: no existing lab covers Gateway API + TLS. Write new material (see aks-series-ops/instructor-notes.md). -->

| | |
|---|---|
| **Outcome** | Serve the app over HTTPS through Gateway API, and troubleshoot traffic between pods, Services and DNS |
| **Cost** | Course cluster plus one public IP, about US$0.30/hour. Azure's managed gateway option is shown by the instructor only |
| **Builds on** | Session 3 |

## What you'll learn

- How pods get IP addresses with Azure CNI overlay (pod range vs node subnet), and how Cilium replaces kube-proxy with eBPF.
- Services in depth: ClusterIP, LoadBalancer, and how endpoints follow readiness.
- Service discovery with CoreDNS: `payments-api.payments.svc.cluster.local`.
- Ingress vs **Gateway API** (GatewayClass, Gateway, HTTPRoute), and why new work uses Gateway API.
- TLS termination with cert-manager. A lab CA today; Let's Encrypt once you own a domain.
- On Azure: Application Gateway for Containers and the application routing add-on, compared.

## Agenda

| Time (IST) | Block |
|---|---|
| 10:00 | Recap of last session and your questions (10 min) |
| 10:10 | Concepts (30 min) |
| 10:40 | Live demo and guided lab (50 min) |
| 11:30 | Troubleshooting and Q&A (25 min) |
| 11:55 | Assignment and what's next (5 min) |

## Demo and lab flow

1. Compare pod IPs and node IPs. Trace a request from a debug pod to a Service to a pod.
2. Resolve Service names from inside a pod, and break DNS on purpose to read the symptoms.
3. Switch the app's Service back to ClusterIP and install a Gateway API implementation.
4. Create a Gateway and an HTTPRoute, and reach the app through the gateway's public IP.
5. Install cert-manager, issue a certificate, and serve HTTPS. `curl -v` shows the TLS handshake.
6. Break and fix: wrong Service port, selector typo, missing route. Preview: a NetworkPolicy that blocks traffic (Session 9).

## How the app grows

The app is reachable only through an HTTPS route. The Service stops being a public load balancer.

## Reference material

- [regulated-k8s-reference: troubleshooting](https://github.com/sathpal/regulated-k8s-reference/blob/main/aks/09-troubleshooting.md), sections 9 (Service selector typo), 10 (NetworkPolicy blocks traffic) and 11 (DNS from inside a pod)
- [regulated-k8s-reference: VMs and AKS nodes](https://github.com/sathpal/regulated-k8s-reference/blob/main/aks/03-vms-and-aks-nodes.md), section 8 (block IMDS for a namespace, and break DNS on the way)

## Assignment (draft)

Serve the app on HTTPS at a hostname of your choice, and post the `curl -v` handshake lines.
