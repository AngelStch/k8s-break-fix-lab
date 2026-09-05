# Kubernetes Break-and-Fix Lab & RCA Journal

A single-node k3s cluster running a small Node.js API against PostgreSQL, monitored by Prometheus, Grafana and Loki. Each scenario deliberately breaks the cluster in a way that mirrors a real customer ticket. The exercise is to diagnose it from logs, events, metrics and traces, then write a one-page root cause analysis.

The point is not the fix. The point is the evidence trail.

## Stack

| Layer | Component |
|---|---|
| Host | macOS running an Ubuntu 24.04 VM via Multipass |
| Cluster | k3s (Traefik ingress, CoreDNS, local-path storage) |
| Workload | `orders-api` (Node.js 22, `pg`, `prom-client`) in namespace `lab` |
| Database | PostgreSQL 16 StatefulSet, `max_connections=20` |
| Metrics | kube-prometheus-stack (Prometheus, Grafana, Alertmanager) |
| Logs | Loki + Promtail |

## Setup

```bash
# On the Mac
brew install multipass
./setup/00-vm.sh                 # creates VM "k3s-lab" and mounts this repo at /lab

# Inside the VM (multipass shell k3s-lab)
cd /lab
sudo ./setup/01-k3s.sh           # k3s, helm, kubectl alias, faketime, psql client
./setup/02-observability.sh      # Prometheus, Grafana, Loki
./setup/03-deploy.sh             # TLS cert, postgres, orders-api, ingress
./scripts/smoke.sh               # confirms everything is green
```

Grafana: `kubectl -n monitoring port-forward svc/kube-prometheus-stack-grafana 3000:80` → http://localhost:3000 (admin / prom-operator).

## Scenarios

| # | Failure | Customer-facing symptom |
|---|---|---|
| 01 | [Expired TLS certificate](scenarios/01-expired-tls/) | Browser and API clients refuse to connect |
| 02 | [CoreDNS misconfiguration](scenarios/02-dns-misconfig/) | App returns 500, cannot reach the database by name |
| 03 | [OOM-killed pods](scenarios/03-oom-killed/) | Intermittent 502s, pods restart in a loop |
| 04 | [Exhausted DB connections](scenarios/04-db-connections-exhausted/) | Requests hang, then fail with "too many clients" |
| 05 | [Clock skew](scenarios/05-clock-skew/) | Certificates "not yet valid", logs vanish from Loki |

Each scenario folder contains `break.sh`, `restore.sh` and a README that describes only the symptom a customer would report. Diagnose before reading the hints section.

## Method

Every RCA follows the same five headings, in order: **Symptom → Evidence → Hypothesis → Test → Fix**. Use [`rca/TEMPLATE.md`](rca/TEMPLATE.md). Paste real command output; never paraphrase evidence. The [troubleshooting cheatsheet](docs/TROUBLESHOOTING-CHEATSHEET.md) lists the commands used most.

## RCA journal

| # | Scenario | RCA |
|---|---|---|
| 01 | Expired TLS certificate | [rca/01-expired-tls.md](rca/01-expired-tls.md) |
| 02 | CoreDNS misconfiguration | [rca/02-dns-misconfig.md](rca/02-dns-misconfig.md) |
| 03 | OOM-killed pods | [rca/03-oom-killed.md](rca/03-oom-killed.md) |
| 04 | Exhausted DB connections | [rca/04-db-connections-exhausted.md](rca/04-db-connections-exhausted.md) |
| 05 | Clock skew | [rca/05-clock-skew.md](rca/05-clock-skew.md) |
