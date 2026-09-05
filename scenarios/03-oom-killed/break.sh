#!/usr/bin/env bash
set -euo pipefail
kubectl -n lab set resources deploy/orders-api --limits=memory=96Mi --requests=memory=48Mi
kubectl -n lab rollout status deploy/orders-api --timeout=300s
echo "Limit lowered to 96Mi. Now call /leak repeatedly and watch: kubectl -n lab get pods -w"
