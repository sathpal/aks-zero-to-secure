# Session 01: AKS 101: Containers, Kubernetes and Azure

**Sat 9 Jan 2027 · 10:00–12:00 IST · live on Microsoft Teams** · recording and slides: see the session pack post in the `01 – AKS 101` channel, or the [YouTube playlist](../../README.md#recordings)

| | |
|---|---|
| **Outcome** | Containerise the course app and run it on a Kubernetes cluster on your own laptop |
| **Cost** | Free. Nothing in this session touches Azure |
| **Lab time on your own** | 45–60 minutes |
| **You need** | Docker, kind, kubectl and git ([PREREQUISITES.md](../../PREREQUISITES.md)) |

## What you'll learn

- Why containers exist: one artefact that runs the same on a laptop, in CI and on a cluster.
- What goes into an image, and why its **size** and its **user** matter. You'll build the same app two ways and compare them.
- The Kubernetes building blocks: cluster, control plane, node, pod, Deployment, Service, namespace, and the idea of *desired state*.
- Where AKS fits: what Microsoft runs for you, and what you run and pay for.

## Agenda

| Time (IST) | Block |
|---|---|
| 10:00 | Welcome and how the series works (10 min) |
| 10:10 | Concepts: containers → Kubernetes → AKS (30 min) |
| 10:40 | Live demo, follow along with Parts 1–4 below (50 min) |
| 11:30 | Troubleshooting and Q&A (25 min) |
| 11:55 | Assignment and what's next (5 min) |

## Lab

### Part 0: Check your tools (5 min)

```bash
docker version --format '{{.Server.Version}}'   # prints a version, not "Cannot connect"
kind version
kubectl version --client
git clone https://github.com/sathpal/aks-zero-to-secure.git
cd aks-zero-to-secure
```

On Windows, run every command in a WSL2 (Ubuntu) terminal.

### Part 1: Build the same app two ways (15 min)

The course app is [`payments-api`](../../app/README.md), a small payments service written in Go. It has two Dockerfiles:

- [`Dockerfile.naive`](../../app/Dockerfile.naive) is the one-stage build most people write first.
- [`Dockerfile`](../../app/Dockerfile) is a two-stage build. A *build* stage runs the tests and compiles. A tiny *runtime* stage receives only the finished binary.

```bash
docker build -f app/Dockerfile.naive -t payments-api:naive app
docker build -t payments-api:1.0 --build-arg VERSION=1.0 app
docker images payments-api
```

| Image | Size we measured | Runs as | Has a shell? |
|---|---|---|---|
| `payments-api:naive` | about 1.4 GB | root (uid 0) | yes, plus the Go toolchain and apt |
| `payments-api:1.0` | about 16 MB | uid 65532 (non-root) | no |

Check both claims yourself:

```bash
docker run --rm --entrypoint id payments-api:naive   # uid=0(root) gid=0(root) groups=0(root)
docker run --rm --entrypoint sh payments-api:1.0     # fails: exec: "sh": executable file not found in $PATH
docker inspect --format 'user={{.Config.User}}' payments-api:1.0   # user=65532
```

Smaller means faster pulls and fewer packages for scanners to flag. No root and no shell means an attacker who breaks in gets less to work with. Session 10 builds on this.

### Part 2: Run it as a container (10 min)

```bash
docker run -d --name pay -p 8080:8080 payments-api:1.0
curl localhost:8080/            # {"pod":"<container id>","service":"payments-api","uid":65532,"version":"1.0"}
curl localhost:8080/healthz     # ok

# Take a payment. 4111 1111 1111 1111 is a standard test card number, never a real one.
curl -X POST localhost:8080/v1/payments \
  -H 'Idempotency-Key: demo-1' -H 'Content-Type: application/json' \
  -d '{"amount_minor":49900,"currency":"INR","card_number":"4111111111111111"}'
```

Run the same `POST` again. You get the **same** payment id back, with status 200 instead of 201. The `Idempotency-Key` header means a retry never charges twice. Now look at the logs:

```bash
docker logs pay      # one JSON audit line per request; the card number never appears
docker rm -f pay
```

If port 8080 is already in use, change it to `-p 18080:8080` and curl `localhost:18080`.

### Part 3: Your first Kubernetes cluster, on your laptop (20 min)

[kind](https://kind.sigs.k8s.io/) runs a whole Kubernetes cluster inside one Docker container.

```bash
kind create cluster --name aks101          # 1–2 minutes
kubectl get nodes                          # one node: aks101-control-plane, Ready
kind load docker-image payments-api:1.0 --name aks101   # copy your image into the cluster
kubectl apply -f sessions/01-aks-101/lab/
kubectl -n aks101 get pods -o wide
```

Read the three files you just applied. Each has a comment explaining it:

- [`00-namespace.yaml`](lab/00-namespace.yaml) is a folder for this session's objects.
- [`10-deployment.yaml`](lab/10-deployment.yaml) says "keep 2 copies of payments-api:1.0 running".
- [`20-service.yaml`](lab/20-service.yaml) is one stable name, `payments-api`, that spreads requests across those copies.

**Which pod answered?** Start a throwaway pod inside the cluster and call the Service six times:

```bash
kubectl -n aks101 run curl --rm -i --restart=Never --image=curlimages/curl:8.11.1 --quiet -- \
  sh -c 'sleep 2; for i in 1 2 3 4 5 6; do curl -s http://payments-api/; done'
```

The `pod` field alternates between your two pods. That is the Service load-balancing.

**Self-healing.** Delete a pod and watch Kubernetes replace it to get back to the desired state:

```bash
kubectl -n aks101 delete pod -l app.kubernetes.io/name=payments-api --wait=false
kubectl -n aks101 get pods -w          # new pods appear within seconds; Ctrl+C to stop watching
```

**Scaling** is just a new desired number:

```bash
kubectl -n aks101 scale deploy/payments-api --replicas=4
kubectl -n aks101 get pods
```

> **Notice:** each pod keeps payments in its own memory. Create a payment through the Service, then fetch it a few times:
>
> ```bash
> kubectl -n aks101 run state --rm -i --restart=Never --image=curlimages/curl:8.11.1 --quiet -- sh -c 'sleep 2;
>   ID=$(curl -s -X POST http://payments-api/v1/payments -H "Idempotency-Key: s1" \
>     -d "{\"amount_minor\":49900,\"currency\":\"INR\",\"card_number\":\"4111111111111111\"}" | sed "s/.*\"id\":\"\([^\"]*\)\".*/\1/");
>   for i in 1 2 3 4 5 6; do curl -s -o /dev/null -w "%{http_code} " http://payments-api/v1/payments/$ID; done; echo'
> ```
>
> Some requests return `404`: they reached a pod that never saw the payment. Hold that thought until Session 5 (storage and state).

### Part 4: Ship version 1.1, then take it back (10 min)

```bash
docker build -t payments-api:1.1 --build-arg VERSION=1.1 app
kind load docker-image payments-api:1.1 --name aks101
kubectl -n aks101 set image deploy/payments-api app=payments-api:1.1
kubectl -n aks101 rollout status deploy/payments-api
kubectl -n aks101 rollout history deploy/payments-api
kubectl -n aks101 rollout undo deploy/payments-api        # back to 1.0
```

Run the "which pod answered?" loop after each step and watch `version` change.

### Part 5: Clean up

```bash
./sessions/01-aks-101/cleanup.sh     # deletes the kind cluster and the images
```

## From kind to AKS: what changes in Session 2

| Today, on kind | On AKS (Session 2) |
|---|---|
| The control plane runs in a Docker container you own | Microsoft runs the control plane. On the Free tier there's no control-plane fee |
| One node is one Docker container | Nodes are Azure VMs in a VM scale set, billed per hour |
| `kind load docker-image` copies the image in | Nodes pull images from Azure Container Registry (ACR) |
| The Service is reachable only inside the cluster | A `type: LoadBalancer` Service gets a public IP from Azure |
| `kind delete cluster` cleans up | `./infra/destroy.sh` deletes the resource group |

## Troubleshooting

| Symptom | Fix |
|---|---|
| `Cannot connect to the Docker daemon` | Start Docker Desktop (or your Docker engine) and wait until it says it's running. |
| Pods stuck in `ErrImagePull` / `ImagePullBackOff` | You skipped `kind load`, or the tag differs. Run `kind load docker-image payments-api:1.0 --name aks101`. |
| `port is already allocated` | Something else is using 8080. Use `-p 18080:8080`. |
| `docker build` can't reach `cgr.dev` (corporate network) | Use other minimal images: `docker build -t payments-api:1.0 --build-arg VERSION=1.0 --build-arg BUILD_IMAGE=golang:1.25 --build-arg RUNTIME_IMAGE=gcr.io/distroless/static-debian12:nonroot app` |
| `kind create cluster` hangs on Windows | Make sure Docker Desktop uses the WSL2 backend, and run kind from the WSL2 terminal. |

Still stuck? Open a [lab-help issue](https://github.com/sathpal/aks-zero-to-secure/issues/new?template=lab-help.yml), or post in the Teams `Help and Discussion` channel with the command and its full output.

## Assignment

Post your answers in [GitHub Discussions](https://github.com/sathpal/aks-zero-to-secure/discussions), under **Session 01**:

1. What size is each image on your machine? Name three things that make the naive one bigger.
2. Delete a pod and time how long it takes until its replacement is `Running`.
3. Why did some `GET` requests return `404` in the "Notice" step?

Stretch: run the "which pod answered?" loop *during* a rollout to 1.2. Did any request fail? Session 3 explains why it can, and how to stop it.

## Before Session 2 (Sat 23 Jan)

Session 2 uses Azure, so get ready ahead of time:

- An Azure subscription where you are **Owner**. A new [Azure free account](https://azure.microsoft.com/free/) works.
- Install the Azure CLI, then run `az login`. See [PREREQUISITES.md](../../PREREQUISITES.md#azure-from-session-2).
- Set a budget alert: `./infra/budget.sh <amount> <your-email>`.
