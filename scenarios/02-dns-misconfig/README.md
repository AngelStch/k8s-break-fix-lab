# 02 · CoreDNS misconfiguration

## Ticket

> The API returns HTTP 500 on every order request since a "platform maintenance" last night. Health check still says OK. The database team says the database is up and accepting connections.

## Break

```bash
./scenarios/02-dns-misconfig/break.sh
```

## Restore

```bash
./scenarios/02-dns-misconfig/restore.sh
```

## Where to look

<details><summary>Hints</summary>

- App logs first: `kubectl -n lab logs deploy/orders-api --since=5m | jq -r '.msg + " " + (.code // "") + " " + (.error // "")'`
- `ENOTFOUND` / `EAI_AGAIN` point at name resolution, not at the database.
- Resolve from inside a pod: `kubectl -n lab run dns-test --rm -it --image=busybox:1.36 --restart=Never -- nslookup postgres.lab.svc.cluster.local`
- Compare with the endpoint list: `kubectl -n lab get endpoints postgres`
- CoreDNS config: `kubectl -n kube-system get configmap coredns -o yaml` — look for anything that was not there in a stock k3s install.
- CoreDNS logs: `kubectl -n kube-system logs deploy/coredns`
- Why did `/health` stay green? Because it does not touch the database. Note this in the RCA as a monitoring gap.

</details>
