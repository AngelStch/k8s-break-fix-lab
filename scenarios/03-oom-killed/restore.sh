#!/usr/bin/env bash
set -euo pipefail
kubectl -n lab set resources deploy/orders-api --limits=memory=256Mi --requests=memory=64Mi
kubectl -n lab rollout status deploy/orders-api --timeout=300s
echo "Restored."
