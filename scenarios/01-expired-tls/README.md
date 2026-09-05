# 01 · Expired TLS certificate

## Ticket as the customer would write it

> Since this morning nobody can open the orders portal. Chrome shows a red warning and our integration scripts fail with a certificate error. Nothing was changed on our side.

## Break

```bash
./scenarios/01-expired-tls/break.sh
```

## Restore

```bash
./scenarios/01-expired-tls/restore.sh
```

## Where to look (read only after you have a hypothesis)

<details><summary>Hints</summary>

- `curl -v https://orders.lab.local/health` — read the TLS handshake lines, not the HTTP ones.
- `openssl s_client -connect 127.0.0.1:443 -servername orders.lab.local | openssl x509 -noout -dates`
- `kubectl -n lab get secret orders-tls -o jsonpath='{.data.tls\.crt}' | base64 -d | openssl x509 -noout -dates -subject`
- Traefik logs: `kubectl -n kube-system logs deploy/traefik | grep -i cert`
- Which component owns certificate renewal here? Nobody. That is the root cause; the expiry is the trigger.

</details>
