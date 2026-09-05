#!/usr/bin/env bash
# Run inside the VM as root. Installs k3s, helm and the tools used by the scenarios.
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
apt-get update -q
apt-get install -y -q curl jq faketime postgresql-client dnsutils openssl

curl -sfL https://get.k3s.io | sh -
mkdir -p /home/ubuntu/.kube
cp /etc/rancher/k3s/k3s.yaml /home/ubuntu/.kube/config
chown -R ubuntu:ubuntu /home/ubuntu/.kube
chmod 600 /home/ubuntu/.kube/config

curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# orders.lab.local resolves to the node so curl works from inside the VM
grep -q orders.lab.local /etc/hosts || echo "127.0.0.1 orders.lab.local" >> /etc/hosts

echo "Waiting for node to be Ready..."
until kubectl get nodes 2>/dev/null | grep -q ' Ready'; do sleep 3; done
kubectl get nodes -o wide
echo "k3s ready. Log out and back in as ubuntu, then run ./setup/02-observability.sh"
