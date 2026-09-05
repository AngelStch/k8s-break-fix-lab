#!/usr/bin/env bash
# Adds a rewrite rule to CoreDNS so the postgres service name resolves to a name that does not exist.
set -euo pipefail
kubectl -n kube-system get configmap coredns -o yaml > /tmp/coredns-backup.yaml
kubectl -n kube-system get configmap coredns -o jsonpath='{.data.Corefile}' > /tmp/Corefile
# Insert the rewrite right after the opening ".:53 {" line.
awk 'NR==1 {print; print "    rewrite name exact postgres.lab.svc.cluster.local postgres-old.lab.svc.cluster.local"; next} {print}' \
  /tmp/Corefile > /tmp/Corefile.broken
kubectl -n kube-system patch configmap coredns --type merge \
  -p "$(jq -n --rawfile cf /tmp/Corefile.broken '{data:{Corefile:$cf}}')"
kubectl -n kube-system rollout restart deploy/coredns
kubectl -n kube-system rollout status deploy/coredns --timeout=60s
# Force the app to re-resolve and reconnect
kubectl -n lab rollout restart deploy/orders-api
echo "Broken. Backup at /tmp/coredns-backup.yaml. Reproduce with: curl -sk https://orders.lab.local/orders"
