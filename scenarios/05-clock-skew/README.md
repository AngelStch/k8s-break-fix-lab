# 05 · Clock skew

## Ticket

> After a hypervisor migration the API host shows "certificate is not yet valid" and our logging dashboard has no entries from that host since the migration. The certificate was renewed last week and is definitely valid.

## Break (inside the VM)

```bash
sudo ./scenarios/05-clock-skew/break.sh      # sets the VM clock 10 days into the past
```

## Restore

```bash
sudo ./scenarios/05-clock-skew/restore.sh
```

## Where to look

<details><summary>Hints</summary>

- `date` and `timedatectl` on the node. Compare with `openssl x509 -noout -dates` on the cert: `notBefore` is in the "future".
- `curl -v https://orders.lab.local/health` from the VM — "certificate is not yet valid".
- Loki: Promtail logs show `entry too far behind` / `timestamp too old` (`kubectl -n monitoring logs ds/loki-promtail`). Loki rejects samples outside its accepted window, so logs are dropped, not delayed.
- Prometheus will show a gap or "out of order" warnings. Grafana panels look empty because the time picker is "now-1h" in real time.
- Kubernetes itself: `kubectl get events -A --sort-by=.lastTimestamp` — token and certificate validation can start failing on a larger skew.
- Root cause is NTP being disabled, not the certificate. The RCA should recommend a clock-skew alert (`node_timex_offset_seconds`).

</details>
