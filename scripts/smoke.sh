#!/usr/bin/env bash
# Quick health check of the whole lab. Green output = baseline state.
set -uo pipefail
echo "== nodes";        kubectl get nodes
echo "== lab pods";     kubectl -n lab get pods -o wide
echo "== monitoring";   kubectl -n monitoring get pods --no-headers | awk '{print $1, $3}' | column -t
echo "== ingress TLS";  echo | openssl s_client -connect 127.0.0.1:443 -servername orders.lab.local 2>/dev/null | openssl x509 -noout -dates
echo "== API";
curl -sk https://orders.lab.local/health && echo
curl -sk -X POST https://orders.lab.local/orders && echo
curl -sk https://orders.lab.local/orders | head -c 300 && echo
