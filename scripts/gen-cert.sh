#!/usr/bin/env bash
# Generates a self-signed cert for orders.lab.local and stores it as secret lab/orders-tls.
# Usage: gen-cert.sh valid | expired
set -euo pipefail
MODE="${1:-valid}"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

CMD=(openssl req -x509 -newkey rsa:2048 -nodes -keyout "$TMP/tls.key" -out "$TMP/tls.crt" \
     -subj "/CN=orders.lab.local" -addext "subjectAltName=DNS:orders.lab.local")

case "$MODE" in
  valid)   "${CMD[@]}" -days 365 ;;
  # Issued 400 days ago, valid 30 days: expired 370 days ago.
  expired) faketime "$(date -d '-400 days' +%F)" "${CMD[@]}" -days 30 ;;
  *) echo "usage: $0 valid|expired"; exit 1 ;;
esac

kubectl -n lab create secret tls orders-tls --cert="$TMP/tls.crt" --key="$TMP/tls.key" \
  --dry-run=client -o yaml | kubectl apply -f -
echo "orders-tls secret updated ($MODE):"
openssl x509 -in "$TMP/tls.crt" -noout -dates
