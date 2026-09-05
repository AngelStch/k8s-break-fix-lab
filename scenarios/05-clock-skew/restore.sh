#!/usr/bin/env bash
set -euo pipefail
timedatectl set-ntp true
sleep 5
echo "NTP re-enabled. Clock now: $(date)"
