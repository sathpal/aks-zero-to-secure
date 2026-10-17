# infra: the course cluster

Run every script from the repository root. The first run picks names (with a random suffix for the registry) and saves them to `infra/.lab.env`. Later scripts and sessions reuse them. Load them into your shell with `source infra/.lab.env`.

| Script | What it does | Time |
|---|---|---|
| [`create-cluster.sh`](create-cluster.sh) | Resource group, Basic registry, AKS cluster: Free tier, 2 × Standard_D2s_v5 nodes, Azure CNI overlay + Cilium, workload identity. Also gets your kubeconfig | ~10 min |
| [`destroy.sh`](destroy.sh) | Lists, asks, then deletes the resource group and everything in it | ~5–10 min |
| [`stop.sh`](stop.sh) / [`start.sh`](start.sh) | Pause and resume the cluster. Node VMs stop billing; the registry and IPs don't | ~3–5 min |
| [`budget.sh`](budget.sh) | Monthly budget with email alerts at 50% and 80% of actual spend, and 100% of forecast | seconds |
| [`create-automatic.sh`](create-automatic.sh) | Instructor demo: AKS Automatic, for the Session 2 comparison. Needs 16 vCPUs of quota | 20–35 min |

## What it costs (Central India list prices, Oct 2026)

| Item | Price |
|---|---|
| Standard_D2s_v5 node | ~US$0.10/hour each |
| Standard_B2s node (cheaper alternative) | ~US$0.045/hour each |
| AKS control plane, Free tier | no fee |
| AKS control plane, Standard tier (production SLA) | ~US$0.10/hour |
| Container Registry, Basic | ~US$0.17/day |
| Public IPv4 address | ~US$0.005/hour |

With the defaults, the course cluster costs **about US$0.30/hour** including disks and the load balancer. That's about US$1 for a two-hour lab.

## Overrides

Set these on the **first** run, or delete `infra/.lab.env` to change them later:

```bash
LOC=southindia ./infra/create-cluster.sh                          # another region
NODE_SIZE=Standard_B2s NODE_COUNT=1 ./infra/create-cluster.sh     # smallest and cheapest
```
