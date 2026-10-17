# payments-api

The one app the whole series works on. It's a small payments service in Go with no dependencies outside the standard library. It already behaves the way a regulated service must:

- Card numbers are never logged or returned in full. Responses show `411111******1111`.
- Every request writes one JSON audit line to stdout, with a request id.
- `POST /v1/payments` is **idempotent** on the `Idempotency-Key` header, so a retry never charges twice.
- On shutdown, `/readyz` fails first, so Kubernetes stops sending traffic before the process exits.

## Endpoints

| Method and path | Returns |
|---|---|
| `GET /` | Which pod answered: `{"pod":"…","service":"payments-api","uid":65532,"version":"1.0"}` |
| `GET /healthz` | `ok`: the process is alive (liveness and startup probes) |
| `GET /readyz` | `ready`, or 503 while draining or when `FAIL_READINESS=true` (readiness probe) |
| `GET /version` | `{"service":"payments-api","version":"1.0"}` |
| `POST /v1/payments` | Creates a payment. Needs an `Idempotency-Key` header and `{"amount_minor":49900,"currency":"INR","card_number":"4111111111111111"}` |
| `GET /v1/payments/{id}` | The payment, or 404 |

## Settings

| Variable | Default | Meaning |
|---|---|---|
| `PORT` | `8080` | Port to listen on |
| `DRAIN_SECONDS` | `5` | How long to fail readiness before shutting down |
| `FAIL_READINESS` | unset | `true` simulates a bad release, used in the Session 3 drill |

## Build and run

```bash
# from the repository root
(cd app && go test ./...)                                   # optional; the Docker build runs the tests too
docker build -t payments-api:1.0 --build-arg VERSION=1.0 app
docker run --rm -p 8080:8080 payments-api:1.0
```

## How it grows through the series

| Session | Change |
|---|---|
| 01 | Built two ways (naive vs hardened); runs in Docker, then on kind |
| 02 | Built in Azure Container Registry; runs on AKS behind a public load balancer |
| 03 | Probes, requests and limits, rollout strategy, ConfigMap and Secret, Kustomize overlays |
| 04 | Reachable only over HTTPS through Gateway API |
| 05 | Optional file-backed store (`DATA_DIR`) on a persistent volume |
| 06 | Helm chart; built and deployed by GitHub Actions and Flux |
| 07 | `/metrics`, OpenTelemetry tracing, `SLOW_MS` latency drill |
| 08 | HPA, PodDisruptionBudget, zone spread, KEDA |
| 09 | Workload identity reads a Key Vault secret; restricted security context; network policy |
| 10 | Base images pinned by digest; scanned, SBOM attached, signed, verified at admission |

The code comes from [regulated-k8s-reference](https://github.com/sathpal/regulated-k8s-reference/tree/main/apps/payments-api). The course added `GET /` so you can see load-balancing.
