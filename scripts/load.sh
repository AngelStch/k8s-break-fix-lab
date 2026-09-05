#!/usr/bin/env bash
# Generates steady traffic so graphs and logs have something to show. Ctrl-C to stop.
while true; do
  curl -sk -o /dev/null -w "%{http_code} " https://orders.lab.local/orders
  curl -sk -o /dev/null -w "%{http_code}\n" -X POST https://orders.lab.local/orders
  sleep 0.5
done
