# Session 02: Your First AKS Cluster

**Sat 23 Jan 2027 · 10:00–12:00 IST · live on Microsoft Teams** · recording and slides: see the session pack post in the `02 – First AKS Cluster` channel, or the [YouTube playlist](../../README.md#recordings)

| | |
|---|---|
| **Outcome** | Create an AKS cluster, put the app's image in Azure Container Registry, serve it on a public IP, then delete it all |
| **Cost** | About **US$0.30/hour** while it runs: 2 × Standard_D2s_v5 nodes (about $0.20), plus OS disks, load balancer, public IPs and a Basic registry (about $0.17/day). Finish within 2 hours and delete: **about US$1**. Central India list prices, Oct 2026 |
| **Lab time on your own** | 60–90 minutes, including about 10 minutes waiting for the cluster |
| **You need** | Session 1 tools, the Azure CLI, and a subscription where you're Owner ([PREREQUISITES.md](../../PREREQUISITES.md#azure-from-session-2)) |

## What you'll learn

- The Azure basics AKS sits on: subscription, region, resource group, and the *node resource group* (`MC_…`) where your VMs live.
- **AKS Standard vs AKS Automatic**, and the Free / Standard / Premium tiers.
- Node pools (system and user) and VM scale sets: what a "node" is in Azure, and what you pay for.
- Azure Container Registry (ACR), and how the cluster gets permission to pull from it.
- `az aks get-credentials` and your kubeconfig.
- A `type: LoadBalancer` Service: how a public IP appears.

## Agenda

| Time (IST) | Block |
|---|---|
| 10:00 | Recap of Session 1 and your questions (10 min) |
| 10:10 | Concepts: Azure building blocks, Standard vs Automatic, tiers, node pools (30 min) |
| 10:40 | Live demo, follow along with Parts 1–6 (50 min) |
| 11:30 | Troubleshooting and Q&A (25 min) |
| 11:55 | Assignment and what's next (5 min) |

## Lab

### Part 0: Sign in and set a budget (5 min)

```bash
az login
az account show --query "{name:name, id:id, user:user.name}" -o table   # the subscription you'll be billed on
az account set --subscription "<name or id>"                           # only if it's the wrong one
./infra/budget.sh 1500 you@example.com   # alerts at 50% and 80%, in your billing currency (e.g. INR 1,500)
```

### Part 1: Check you have room for two nodes (2 min)

```bash
az vm list-usage -l centralindia -o table \
  --query "[?name.value=='cores' || name.value=='standardDSv5Family'].{quota:localName, used:currentValue, limit:limit}"
```

You need at least 4 free vCPUs in both rows. If you don't have them, see [Troubleshooting](#troubleshooting).

### Part 2: Create the cluster (about 10 minutes of waiting)

```bash
./infra/create-cluster.sh
```

While it runs, read [`infra/create-cluster.sh`](../../infra/create-cluster.sh). Each choice:

| Flag | Why |
|---|---|
| `--tier free` | No control-plane fee and no uptime SLA, which is right for learning. Production uses `standard` (about US$0.10/hour per cluster) |
| `--node-count 2 --node-vm-size Standard_D2s_v5` | Two small general-purpose VMs, 2 vCPU and 8 GiB each |
| `--os-sku AzureLinux` | Microsoft's minimal Linux for container hosts |
| `--network-plugin azure --network-plugin-mode overlay --network-dataplane cilium` | Pods get IPs from a private range, not your VNet. Cilium enforces network policy (Session 4). Network choices can't be changed later |
| `--enable-oidc-issuer --enable-workload-identity` | Lets pods sign in to Azure without passwords (Session 9) |
| `--attach-acr` | Grants the nodes' identity the `AcrPull` role on your registry |
| `--auto-upgrade-channel patch --node-os-upgrade-channel NodeImage` | Security patches arrive without you doing anything (Session 8) |

### Part 3: Look around (10 min)

```bash
source infra/.lab.env                  # puts RG, AKS, ACR and the rest into your shell
kubectl get nodes -o wide              # two nodes, each an Azure VM
az aks nodepool list -g "$RG" --cluster-name "$AKS" -o table
NODE_RG=$(az aks show -g "$RG" -n "$AKS" --query nodeResourceGroup -o tsv)
az vmss list -g "$NODE_RG" -o table    # the VM scale set behind the node pool: this is what you pay for
kubectl get pods -n kube-system        # what Azure runs for you: CoreDNS, Cilium, metrics-server, ...
```

In the portal, open both resource groups: `$RG` holds the cluster and the registry. `MC_…` holds the VMs, disks, load balancer and network.

### Part 4: Put the image in your registry (10 min)

**Option A: build in Azure.** No local Docker needed. Works on pay-as-you-go subscriptions:

```bash
az acr build -r "$ACR" -t payments-api:1.0 --build-arg VERSION=1.0 app
```

**Option B: build on your laptop and push.** Works everywhere. You **must** use it on free-trial or free-credit subscriptions, where ACR Tasks returns `TasksOperationsNotAllowed`:

```bash
az acr login -n "$ACR"
docker build --platform linux/amd64 -t "$ACR.azurecr.io/payments-api:1.0" --build-arg VERSION=1.0 app
docker push "$ACR.azurecr.io/payments-api:1.0"
```

`--platform linux/amd64` matters on Apple Silicon and other ARM laptops, because the AKS nodes are x86-64. Without it, pods crash with `exec format error`.

```bash
az acr repository show-tags -n "$ACR" --repository payments-api -o table   # 1.0
```

### Part 5: Deploy (10 min)

```bash
kubectl apply -f sessions/02-first-aks-cluster/lab/00-namespace.yaml
sed "s|REGISTRY|$ACR.azurecr.io|" sessions/02-first-aks-cluster/lab/10-deployment.yaml | kubectl apply -f -
kubectl apply -f sessions/02-first-aks-cluster/lab/20-service.yaml
kubectl -n payments rollout status deploy/payments-api
kubectl -n payments get pods -o wide   # the NODE column shows four pods spread over both nodes
```

### Part 6: Your app on the internet (10 min)

```bash
kubectl -n payments get svc payments-api -w        # wait until EXTERNAL-IP is an address, then Ctrl+C
IP=$(kubectl -n payments get svc payments-api -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
for i in 1 2 3 4 5 6; do curl -s "http://$IP/"; done   # different pods answer
curl -X POST "http://$IP/v1/payments" -H 'Idempotency-Key: aks-1' -H 'Content-Type: application/json' \
  -d '{"amount_minor":49900,"currency":"INR","card_number":"4111111111111111"}'
```

In the portal, the `MC_…` group now has a public IP and a load-balancing rule that Kubernetes created for you. This endpoint is plain HTTP and open to anyone, so use test card numbers only. Session 4 puts it behind Gateway API with TLS.

### Part 7 (optional): Break it on purpose

```bash
kubectl -n payments set image deploy/payments-api app=payments-api:1.0   # no registry in the name
kubectl -n payments get pods                                             # ErrImagePull / ImagePullBackOff
kubectl -n payments describe pod -l app.kubernetes.io/name=payments-api | grep -A8 Events
kubectl -n payments rollout undo deploy/payments-api                      # fixed
```

The old pods kept serving the whole time. Kubernetes doesn't remove working pods until new ones are ready.

### Part 8: Instructor demo: AKS Automatic

The instructor created an Automatic cluster before the session with [`infra/create-automatic.sh`](../../infra/create-automatic.sh). It needs 16 vCPUs of quota, so learners only watch. Same app, same manifests. What differs is what you get without asking:

| | AKS Standard (what you built) | AKS Automatic |
|---|---|---|
| Nodes | You pick VM size, count and pools; you turn on autoscaling | Node auto-provisioning picks VM sizes for your workloads |
| Networking | Your choice (here: CNI overlay + Cilium) | CNI overlay + Cilium, preset |
| Access | Local admin accounts allowed by default | Entra ID + Azure RBAC; local accounts disabled |
| Guardrails | Optional | Deployment Safeguards check workloads against best practices |
| Upgrades | You choose channels | Automatic upgrades with maintenance windows |
| Cost | Free tier: no control-plane fee, you pay for VMs | Hosted control plane about US$0.16/hour, plus a per-vCPU fee and VMs |
| Quota to try it | 4 vCPUs | 16 vCPUs in one D-family |

This course uses Standard so you see and choose every setting. Automatic is a strong default once you know what those settings mean.

### Part 9: Clean up (do this today)

```bash
./sessions/02-first-aks-cluster/cleanup.sh    # same as ./infra/destroy.sh: lists what will go, asks, then deletes
```

Pausing instead? `./infra/stop.sh` stops node billing, but the registry and IPs keep costing a little, and you resume with `./infra/start.sh`. Recreating takes about 10 minutes, so for this course, **delete**. Tomorrow, check **Cost Management → Cost analysis** to see what the lab really cost.

## Troubleshooting

| Symptom | Fix |
|---|---|
| `QuotaExceeded` / `InsufficientVCPUQuota` at create | Use smaller or fewer nodes. Delete `infra/.lab.env`, then run `NODE_SIZE=Standard_B2s ./infra/create-cluster.sh` or `NODE_COUNT=1 ./infra/create-cluster.sh`. Or request more quota (**Quotas** in the portal) |
| `SkuNotAvailable` / capacity errors | Try another region. Delete `infra/.lab.env`, then run `LOC=southindia ./infra/create-cluster.sh` |
| `AuthorizationFailed` on `--attach-acr` | You need Owner (or User Access Administrator) on the subscription to create the AcrPull role assignment |
| `TasksOperationsNotAllowed` on `az acr build` | Free-trial or free-credit subscription: use Option B |
| Pods `CrashLoopBackOff` with `exec format error` | The image was built for ARM. Rebuild with `--platform linux/amd64` and push again |
| `EXTERNAL-IP` stays `<pending>` for more than 5 minutes | `kubectl -n payments describe svc payments-api` and read the Events |
| `ResourceGroupBeingDeleted` when recreating | Wait for the previous delete to finish: `az group wait -n "$RG" --deleted` |

Still stuck? Open a [lab-help issue](https://github.com/sathpal/aks-zero-to-secure/issues/new?template=lab-help.yml), or post in the Teams `Help and Discussion` channel with the command and its full output.

## Assignment

Post your answers in [GitHub Discussions](https://github.com/sathpal/aks-zero-to-secure/discussions), under **Session 02**:

1. Deploy version 1.1 from your registry, then show it answering on your public IP.
2. What's the name of your node pool's VM scale set, and how many instances does it have?
3. What did Cost analysis say the lab cost you, the day after?

## Before Session 3 (Sat 13 Feb)

Session 3 starts with `./infra/create-cluster.sh`. Run it 15 minutes before the session starts, then follow along.
