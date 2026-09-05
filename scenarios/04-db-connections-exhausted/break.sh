#!/usr/bin/env bash
# Starts a Job that opens 18 idle connections and holds them for an hour.
set -euo pipefail
kubectl -n lab delete job connection-hog --ignore-not-found
kubectl -n lab apply -f - <<'YAML'
apiVersion: batch/v1
kind: Job
metadata:
  name: connection-hog
  labels:
    app: connection-hog
spec:
  backoffLimit: 0
  template:
    metadata:
      labels:
        app: connection-hog
    spec:
      restartPolicy: Never
      containers:
        - name: hog
          image: postgres:16-alpine
          envFrom:
            - secretRef:
                name: postgres-credentials
          command:
            - sh
            - -c
            - |
              export PGPASSWORD="$POSTGRES_PASSWORD"
              for i in $(seq 1 18); do
                PGAPPNAME="reporting-job-$i" psql -h postgres.lab.svc.cluster.local -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
                  -c "select pg_sleep(3600)" >/dev/null 2>&1 &
              done
              wait
YAML
echo "Broken. 18 of 20 connection slots are now held. Reproduce with: curl -sk https://orders.lab.local/orders"
