#!/usr/bin/env bash
# Run inside the VM as ubuntu. Deploys postgres, orders-api and the TLS ingress.
set -euo pipefail
cd "$(dirname "$0")/.."

kubectl apply -f manifests/00-namespace.yaml
./scripts/gen-cert.sh valid
kubectl apply -f manifests/10-postgres.yaml

# App source ships as a ConfigMap so no image registry is needed
kubectl -n lab create configmap orders-api-src --from-file=app/server.js --from-file=app/package.json \
  --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f manifests/20-app.yaml
kubectl apply -f manifests/30-ingress.yaml

echo "Waiting for rollout..."
kubectl -n lab rollout status statefulset/postgres --timeout=180s
kubectl -n lab rollout status deployment/orders-api --timeout=300s
kubectl -n lab get all
echo "Done. Test with: ./scripts/smoke.sh"
