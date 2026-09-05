# 04 · Exhausted database connections

## Ticket

> Order requests take 3 seconds and then fail. Health is green. The database server has low CPU. A colleague started "a reporting job" earlier today.

## Break

```bash
./scenarios/04-db-connections-exhausted/break.sh
```

## Restore

```bash
./scenarios/04-db-connections-exhausted/restore.sh
```

## Where to look

<details><summary>Hints</summary>

- App logs: Postgres error code `53300` = `too_many_connections`; message "remaining connection slots are reserved" or "sorry, too many clients already". A `connectionTimeoutMillis` of 3000 explains the 3-second delay.
- Inside postgres: `kubectl -n lab exec -it postgres-0 -- psql -U orders -c "select count(*), state, application_name from pg_stat_activity group by 2,3"`
- `show max_connections;` — 20. How many does the app pool want per replica? How many replicas? Do the arithmetic in the RCA.
- Who holds the rest? `select pid, usename, application_name, state, query_start from pg_stat_activity where state='idle' order by query_start`
- Postgres logs: `kubectl -n lab logs postgres-0 | grep -i "too many"`
- Metric: `orders_db_errors_total{code="53300"}` in Prometheus.
- Fix options ranked: kill the rogue job, raise `max_connections`, add a pooler (PgBouncer), lower `PG_POOL_MAX`. Argue for one.

</details>
