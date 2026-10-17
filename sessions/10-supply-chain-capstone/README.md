# Session 10: Secure Software Supply Chain + Capstone

**Sat 12 Jun 2027 · 10:00–12:00 IST · live on Microsoft Teams** · recording and slides: see the session pack post in the session channel, or the [YouTube playlist](../../README.md#recordings)

> **Status: outline.** The full step-by-step lab is published here one week before the session. The outcome and topics are fixed; exact commands may change.

| | |
|---|---|
| **Outcome** | Ship only scanned, signed images you can trace back to a commit, enforce that when pods are admitted, and present your secured deployment |
| **Cost** | Course cluster plus Key Vault. Microsoft Defender for Containers is billed per vCPU and shown with its 30-day free trial |
| **Builds on** | Every session; this is the capstone |

## What you'll learn

- Image scanning (Trivy, Grype). Why minimal base images remove most findings, and how to read the rest.
- SBOMs: yours and the base image's.
- Pinning base images by digest, and keeping the pins fresh automatically.
- Signing and provenance: Notation with a Key Vault key, and keyless cosign from GitHub Actions.
- Admission control: Pod Security Admission, Kyverno policies, and admitting only signed images from your registry.
- What Defender for Containers and Azure Policy add on top.

## Agenda

| Time (IST) | Block |
|---|---|
| 10:00 | Recap of last session and your questions (10 min) |
| 10:10 | Concepts (30 min) |
| 10:40 | Live demo and guided lab (50 min) |
| 11:30 | Troubleshooting and Q&A (25 min) |
| 11:55 | Assignment and what's next (5 min) |

## Demo and lab flow

1. Scan the naive and production images from Session 1, and compare the findings.
2. Generate and inspect SBOMs; verify the base image really comes from its publisher.
3. Pin both base images in [`app/Dockerfile`](../../app/Dockerfile) by digest.
4. Sign the image in CI, and deploy it by digest.
5. Enforce at admission: only your registry, no `latest`, probes and resources required, signed images only.
6. Try to deploy an unsigned image and watch it get refused.
7. Capstone: how projects are reviewed, and a showcase of finished deployments.

## Reference material

- [chainguard-aks-demo hands-on lab](https://github.com/sathpal/chainguard-aks-demo/blob/main/docs/hands-on-lab.md), sections 1–9 (two Dockerfiles, scans, provenance, SBOMs)
- [chainguard-actions-end-to-end](https://github.com/sathpal/chainguard-actions-end-to-end/blob/main/docs/hands-on.md): signing and attestations in CI
- [regulated-k8s-reference: build, sign, deploy](https://github.com/sathpal/regulated-k8s-reference/blob/main/aks/04-build-sign-deploy.md): Key Vault signing and deploy by digest
- [regulated-k8s-reference: security](https://github.com/sathpal/regulated-k8s-reference/blob/main/aks/08-security.md), sections 5 and 7–11 (Pod Security, Kyverno, signed images only, Azure-native options)
- [Kyverno cluster policies](https://github.com/sathpal/regulated-k8s-reference/tree/main/policy/kyverno/cluster): registry allow-list, no `latest`, resources and probes required

## Capstone

See [capstone/RUBRIC.md](../../capstone/RUBRIC.md). Submissions are due **Sat 3 Jul 2027**.
