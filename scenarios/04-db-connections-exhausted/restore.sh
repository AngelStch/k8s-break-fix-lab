#!/usr/bin/env bash
set -euo pipefail
kubectl -n lab delete job connection-hog --ignore-not-found
echo "Restored. Connections release within a few seconds."
