# AKS: From Zero to Secure Production

**Build. Operate. Secure.** A free community series in 10 live sessions on Azure Kubernetes Service (AKS), from your first container to a signed, policy-checked workload running in production shape.

- **When:** Saturdays, 10:00–12:00 IST, from **9 January to 12 June 2027**: the 2nd and 4th Saturday of January–April, then one session in May and one in June.
- **Where:** live on Microsoft Teams. Every session is recorded.
- **How:** one app, [`payments-api`](app/README.md), grows through the whole series. You watch it change each session, and you rebuild it yourself in the labs.

## Schedule

| # | Date | Session | Lab |
|---|---|---|---|
| 01 | Sat 9 Jan 2027 | [AKS 101: Containers, Kubernetes and Azure](sessions/01-aks-101/README.md) | ready |
| 02 | Sat 23 Jan 2027 | [Your First AKS Cluster](sessions/02-first-aks-cluster/README.md) | ready |
| 03 | Sat 13 Feb 2027 | [Deploying Applications Properly](sessions/03-deploying-apps-properly/README.md) | outline |
| 04 | Sat 27 Feb 2027 | [AKS Networking Explained](sessions/04-networking/README.md) | outline |
| 05 | Sat 13 Mar 2027 | [Storage and Stateful Workloads](sessions/05-storage-stateful/README.md) | outline |
| 06 | Sat 27 Mar 2027 | [From Commit to Cluster](sessions/06-commit-to-cluster/README.md) | outline |
| 07 | Sat 10 Apr 2027 | [Observability and Troubleshooting](sessions/07-observability/README.md) | outline |
| 08 | Sat 24 Apr 2027 | [Reliability, Scaling and Cost](sessions/08-reliability-scaling-cost/README.md) | outline |
| 09 | Sat 8 May 2027 | [AKS Security: Identity and Isolation](sessions/09-security-identity-isolation/README.md) | outline |
| 10 | Sat 12 Jun 2027 | [Secure Software Supply Chain + Capstone](sessions/10-supply-chain-capstone/README.md) | outline |

Each full lab is published at least one week before its session. Dates in calendar form are in [SCHEDULE.md](SCHEDULE.md).

## How each session works

| Minutes | Block |
|---|---|
| 10 | Recap and your questions |
| 30 | Concepts and architecture |
| 50 | Live demo and guided lab: follow along, or watch now and do it later |
| 25 | Troubleshooting and Q&A |
| 5 | Assignment and next steps |

Ask questions in the Teams **Q&A** panel during the session; moderators answer or pass them to the instructor. After the session, labs are self-paced. Get help in [GitHub Discussions](https://github.com/sathpal/aks-zero-to-secure/discussions) or the Teams `Help and Discussion` channel ([SUPPORT.md](SUPPORT.md)).

## Join

Each session has its own free registration on Microsoft Teams. The registration form also lets you join the series' Team, which holds the session channels, materials, recordings and discussion. Registration for Sessions 1 and 2 opens on **23 November 2026**.

<!-- TODO(launch): add the registration links and the Team join link here on 23 Nov 2026. -->

## Recordings

Every session is recorded. Within 48 hours, the recording is posted to:

- the session's channel in the Team (with slides, lab links and the assignment), and
- the series' YouTube playlist, for anyone.

<!-- TODO(launch): add the YouTube playlist link here before Session 1. -->

## Completion

To complete the series, attend or watch **8 of the 10 sessions** and submit a [capstone](capstone/RUBRIC.md) that passes review. You'll get a community certificate of completion. It is not a Microsoft certification.

## What you need

A laptop that runs Docker. From Session 2, an Azure subscription where you're Owner. Full list: [PREREQUISITES.md](PREREQUISITES.md).

> **Costs:** Session 1 is free. Every lab after that creates Azure resources that cost money while they exist. Each lab states its cost and ends with teardown steps. Set a budget alert with [`infra/budget.sh`](infra/budget.sh), use a personal or free subscription rather than your employer's production one, and **delete everything when you finish** (`./infra/destroy.sh`).

## Repository layout

```
app/          payments-api: the Go service that evolves through the series, with naive and hardened Dockerfiles
infra/        create, pause, resume and delete the course cluster; budget alert
sessions/     one folder per session: README (lab guide), lab/ manifests, cleanup.sh
capstone/     what to build for the capstone, and how it's reviewed
```

## Code of conduct and licence

Everyone in the series follows the [code of conduct](CODE_OF_CONDUCT.md). Code is [MIT](LICENSE) licensed. Course text is [CC BY 4.0](LICENSE-CONTENT).
