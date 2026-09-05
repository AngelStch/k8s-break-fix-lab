#!/usr/bin/env bash
set -euo pipefail
kubectl apply -f /tmp/coredns-backup.yaml
kubectl -n kube-system rollout restart deploy/coredns
kubectl -n kube-system rollout status deploy/coredns --timeout=60s
kubectl -n lab rollout restart deploy/orders-api
echo "Restored."
