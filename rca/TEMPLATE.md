# RCA NN · <short title>

| | |
|---|---|
| Date | YYYY-MM-DD |
| Component | `lab/orders-api`, Traefik, CoreDNS, PostgreSQL, ... |
| Severity | S1 outage / S2 degraded / S3 cosmetic |
| Time to detect | |
| Time to resolve | |

## Symptom
What the customer reported and what you could observe from outside. One paragraph. No interpretation yet.

## Evidence
Real command output only. Trim, never rewrite. Each block gets a one-line caption stating what it shows.

```text
$ command
output
```

## Hypothesis
The single most likely cause, stated so that it can be proven wrong. If you had two candidates, list both and say which you tested first and why.

## Test
The command or change that confirmed or rejected the hypothesis, and its output.

## Fix
- Immediate: what restored service.
- Root cause: the condition that allowed the failure (a missing renewal process, a missing alert, a missing limit).
- Prevention: the alert, runbook step or config change that would catch it next time.

## Notes for the knowledge base
Two or three lines a colleague could search for six months from now: exact error strings, error codes, the metric that moved.
