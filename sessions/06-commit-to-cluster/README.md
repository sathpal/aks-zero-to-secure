# Session 06: From Commit to Cluster

**Sat 27 Mar 2027 · 10:00–12:00 IST · live on Microsoft Teams** · recording and slides: see the session pack post in the session channel, or the [YouTube playlist](../../README.md#recordings)

> **Status: outline.** The full step-by-step lab is published here one week before the session. The outcome and topics are fixed; exact commands may change.

| | |
|---|---|
| **Outcome** | Push a commit and watch it get built, tested, published to ACR and deployed to AKS, with no passwords stored in GitHub |
| **Cost** | Course cluster and registry. GitHub Actions minutes are free on public repositories |
| **Builds on** | Sessions 2 and 3 |

## What you'll learn

- ACR in more depth: repositories, tags vs digests, and who can push or pull.
- Packaging the app as a Helm chart, and how Helm and Kustomize differ.
- A GitHub Actions workflow that tests, builds and pushes the image.
- **OIDC federation** from GitHub to Azure: a managed identity trusts your repository, so no secret is stored anywhere.
- GitOps with the AKS Flux extension: the cluster pulls its desired state from Git. Push vs pull deployment.
- Promotion between environments, and rolling back by reverting a commit.

## Agenda

| Time (IST) | Block |
|---|---|
| 10:00 | Recap of last session and your questions (10 min) |
| 10:10 | Concepts (30 min) |
| 10:40 | Live demo and guided lab (50 min) |
| 11:30 | Troubleshooting and Q&A (25 min) |
| 11:55 | Assignment and what's next (5 min) |

## Demo and lab flow

1. Fork this repository and create a user-assigned managed identity with a federated credential for your fork.
2. Give the pipeline only `AcrPush` on your registry: least privilege.
3. Add the workflow: test → build → push by digest.
4. Package the app as a Helm chart, and install it by hand once.
5. Install the Flux extension and point it at your fork. Change `replicas` in Git, and the cluster follows.
6. Ship a bad release through the pipeline, then revert the commit and watch Flux undo it.

## Reference material

- [regulated-k8s-reference: CI/CD into AKS](https://github.com/sathpal/regulated-k8s-reference/blob/main/aks/06-cicd-into-aks.md), sections 1 (federated identity), 2 (least privilege), 3 (pipeline), 4 (a bad release undoes itself) and 5 (GitOps with the AKS Flux extension)
- [chainguard-actions-end-to-end](https://github.com/sathpal/chainguard-actions-end-to-end/blob/main/docs/hands-on.md): the same pipeline built twice, upstream vs hardened
- [arc-aks-automatic-demo](https://github.com/sathpal/arc-aks-automatic-demo): optional, GitHub Actions runners on AKS itself

## Assignment (draft)

Make a one-line change in your fork. Post the workflow run link and the Flux reconciliation showing it live.
