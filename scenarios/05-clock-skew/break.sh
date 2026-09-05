#!/usr/bin/env bash
set -euo pipefail
timedatectl set-ntp false
date -s "-10 days"
echo "Clock set to: $(date). NTP disabled. Reproduce with: curl -v https://orders.lab.local/health"
