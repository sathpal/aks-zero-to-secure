# Capstone

Show what you've learned by deploying a secured application on AKS, end to end. Use `payments-api` from this course, or bring a small app of your own.

**Due:** Sat 3 Jul 2027, three weeks after Session 10.

## What to submit

1. A public GitHub repository (a fork of this one is fine) containing:
   - the app and its Dockerfile,
   - the Kubernetes manifests or Helm chart,
   - the pipeline (GitHub Actions), and
   - a `README.md` with an architecture diagram, the controls you applied, what you would do next, and how to tear it all down.
2. Evidence that it ran on AKS: a recording of up to 5 minutes, or screenshots plus command output in the README. Delete the cluster afterwards. Reviewers don't need it running.
3. A post in the **Capstone** category of GitHub Discussions, or in the Teams `Capstone Projects` channel, linking both.

## How it's reviewed

| Area | What reviewers look for | Points |
|---|---|---|
| Build and supply chain | Minimal base image pinned by digest, a scan in CI, an SBOM, and a signed image deployed by digest | 20 |
| Deployment | Pipeline or GitOps deploy, probes, requests and limits, a rollout strategy, a PDB, an HPA | 20 |
| Networking | HTTPS through Gateway API, and default-deny network policy with explicit allows | 15 |
| Identity and secrets | Workload identity, no secrets in Git or the pipeline, Entra ID sign-in with least-privilege RBAC | 20 |
| Observability | A dashboard or query for rate, errors and duration; one alert; a short runbook | 15 |
| Cost and cleanup | A cost estimate and a working teardown | 10 |

**Pass:** 60 points or more, **and** no secrets anywhere in the repository or its history. A committed secret fails the capstone, even after it's deleted: rotate it and resubmit.

Moderators and the instructor review submissions within two weeks of the deadline. A few projects are showcased in a short bonus session.
