#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."
./scripts/gen-cert.sh expired
echo "Broken. Reproduce with: curl -v https://orders.lab.local/health"
