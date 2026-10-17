# Session 07: Observability and Troubleshooting

**Sat 10 Apr 2027 · 10:00–12:00 IST · live on Microsoft Teams** · recording and slides: see the session pack post in the session channel, or the [YouTube playlist](../../README.md#recordings)

> **Status: outline.** The full step-by-step lab is published here one week before the session. The outcome and topics are fixed; exact commands may change.

<!-- instructor: wiring Azure Monitor managed Prometheus + Managed Grafana to the app is new material; add /metrics, tracing and the SLOW_MS drill to the app (see aks-series-ops/instructor-notes.md). -->

| | |
|---|---|
| **Outcome** | Diagnose a failed deployment and a slow application using kubectl, logs, metrics and traces |
| **Cost** | Course cluster plus Azure Monitor (managed Prometheus, Container Insights) and Managed Grafana. Estimate published with the full lab; delete them afterwards |
| **Builds on** | Sessions 3 and 4 |

## What you'll learn

- The troubleshooting loop: `get` → `describe` → `logs` → `events`, and what each failure state means.
- Container Insights and Log Analytics: cluster and container logs in Azure.
- Azure Monitor managed Prometheus and Azure Managed Grafana: metrics without running Prometheus yourself.
- Application metrics with the RED method (rate, errors, duration) from the app's `/metrics`.
- OpenTelemetry traces: the collector, context propagation, and finding the slow span.
- Alerts that page on symptoms, not causes.

## Agenda

| Time (IST) | Block |
|---|---|
| 10:00 | Recap of last session and your questions (10 min) |
| 10:10 | Concepts (30 min) |
| 10:40 | Live demo and guided lab (50 min) |
| 11:30 | Troubleshooting and Q&A (25 min) |
| 11:55 | Assignment and what's next (5 min) |

## Demo and lab flow

1. Ten break-fix drills, one cluster: ImagePullBackOff (twice), CrashLoopBackOff, OOMKilled, Pending, readiness on the wrong port, admission refusal, selector typo, NetworkPolicy, DNS.
2. Turn on managed Prometheus, Container Insights and Managed Grafana for the course cluster.
3. Scrape the app's new `/metrics` and build a RED dashboard.
4. Add OpenTelemetry tracing, inject latency with `SLOW_MS`, and find it in a trace.
5. Create one alert on error rate and trigger it.

## How the app grows

The app gains a Prometheus `/metrics` endpoint, OpenTelemetry tracing and a `SLOW_MS` setting for the latency drill.

## Reference material

- [regulated-k8s-reference: troubleshooting](https://github.com/sathpal/regulated-k8s-reference/blob/main/aks/09-troubleshooting.md): the full set of break-fix drills this session runs

## Assignment (draft)

Pick two drills you didn't see live, break your cluster, and post the one command that showed you the cause.
