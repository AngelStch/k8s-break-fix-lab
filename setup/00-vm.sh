#!/usr/bin/env bash
# Run on the Mac. Creates the Ubuntu VM and mounts this repo at /lab.
set -euo pipefail
VM=k3s-lab
REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"

if multipass info "$VM" >/dev/null 2>&1; then
  echo "VM $VM already exists"
else
  multipass launch 24.04 --name "$VM" --cpus 4 --memory 6G --disk 30G
fi
multipass mount "$REPO_DIR" "$VM":/lab || true
multipass exec "$VM" -- bash -c 'echo "VM ready: $(hostname) $(uname -r)"'
echo
echo "Next: multipass shell $VM   then   cd /lab && sudo ./setup/01-k3s.sh"
