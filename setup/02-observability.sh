#!/usr/bin/env bash
# Run inside the VM as ubuntu. Installs Prometheus, Grafana and Loki.
set -euo pipefail
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  -n monitoring \
  --set grafana.adminPassword=prom-operator \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
  --set prometheus.prometheusSpec.retention=2d \
  --wait --timeout 10m

helm upgrade --install loki grafana/loki-stack \
  -n monitoring \
  --set promtail.enabled=true \
  --set loki.isDefault=false \
  --wait --timeout 10m

# Register Loki as a Grafana datasource
kubectl apply -n monitoring -f - <<'YAML'
apiVersion: v1
kind: ConfigMap
metadata:
  name: loki-datasource
  labels:
    grafana_datasource: "1"
data:
  loki.yaml: |
    apiVersion: 1
    datasources:
      - name: Loki
        type: loki
        access: proxy
        url: http://loki:3100
YAML

kubectl -n monitoring get pods
echo "Observability stack installed. Next: ./setup/03-deploy.sh"
