# Troubleshooting cheatsheet

Ordered the way an investigation usually runs: outside-in, then down the stack.

## From outside
```bash
curl -vk https://orders.lab.local/health            # TLS handshake + HTTP in one view
echo | openssl s_client -connect 127.0.0.1:443 -servername orders.lab.local 2>/dev/null | openssl x509 -noout -dates -subject -issuer
dig +short postgres.lab.svc.cluster.local @10.43.0.10   # k3s CoreDNS service IP
```

## Cluster state
```bash
kubectl get nodes -o wide
kubectl get events -A --sort-by=.lastTimestamp | tail -40
kubectl -n lab get pods -o wide
kubectl -n lab describe pod <pod>                    # Events, Last State, Exit Code, Reason
kubectl -n lab rollout history deploy/orders-api
```

## Logs
```bash
kubectl -n lab logs deploy/orders-api --since=10m --all-containers
kubectl -n lab logs <pod> --previous                 # the container that died
kubectl -n lab logs deploy/orders-api | jq -r 'select(.level=="error") | .ts + " " + .msg + " " + (.code//"") + " " + (.error//"")'
kubectl -n kube-system logs deploy/coredns
kubectl -n kube-system logs deploy/traefik
```

## Inside a pod
```bash
kubectl -n lab exec -it deploy/orders-api -- sh
kubectl -n lab run tmp --rm -it --image=busybox:1.36 --restart=Never -- sh   # nslookup, wget, nc
kubectl -n lab exec -it postgres-0 -- psql -U orders -c "select * from pg_stat_activity"
```

## Resources
```bash
kubectl top pods -n lab
kubectl -n lab get deploy orders-api -o jsonpath='{.spec.template.spec.containers[0].resources}' | jq
```

## Prometheus queries worth memorising
```promql
rate(orders_http_requests_total{status=~"5.."}[5m])
orders_db_errors_total
container_memory_working_set_bytes{namespace="lab",container="orders-api"}
kube_pod_container_status_last_terminated_reason{namespace="lab"}
kube_pod_container_status_restarts_total{namespace="lab"}
node_timex_offset_seconds
```

## Loki (LogQL)
```logql
{namespace="lab", app="orders-api"} | json | level="error"
{namespace="kube-system", app="coredns"} |~ "NXDOMAIN|SERVFAIL"
```

## Exit codes
| Code | Meaning |
|---|---|
| 137 | SIGKILL — almost always OOMKilled when `Reason: OOMKilled` |
| 143 | SIGTERM — graceful stop |
| 1 | application exited with error — read `--previous` logs |

## Postgres error codes
| Code | Meaning |
|---|---|
| 53300 | too_many_connections |
| 28P01 | invalid_password |
| 3D000 | invalid_catalog_name (database does not exist) |
| 08006 | connection_failure |
