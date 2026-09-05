# 03 · OOM-killed pods

## Ticket

> Users see intermittent "502 Bad Gateway". It recovers by itself after a minute and then happens again. Load is normal. It started after we "optimised resource usage" in the cluster.

## Break

```bash
./scenarios/03-oom-killed/break.sh
# then generate the leak:
for i in $(seq 1 20); do curl -sk https://orders.lab.local/leak; echo; sleep 1; done
```

## Restore

```bash
./scenarios/03-oom-killed/restore.sh
```

## Where to look

<details><summary>Hints</summary>

- `kubectl -n lab get pods -w` — watch RESTARTS climb.
- `kubectl -n lab describe pod <pod>` — `Last State: Terminated`, `Reason: OOMKilled`, `Exit Code: 137`.
- `kubectl -n lab logs <pod> --previous` — the last lines before death. Note the `rss_mb` values.
- Prometheus: `container_memory_working_set_bytes{namespace="lab"}` against `kube_pod_container_resource_limits{resource="memory"}`.
- `kubectl -n lab get deploy orders-api -o jsonpath='{.spec.template.spec.containers[0].resources}'`
- Two distinct causes: a limit that is too low, and an application that leaks. Your RCA must separate the two. Which would you fix first in production, and why?

</details>
