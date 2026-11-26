#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
require istioctl; require python
python scripts/validate.py
connect
version=$(istioctl version --remote=false)
[[ "$version" == *"$ISTIO_VERSION"* ]] || { echo "Usa istioctl $ISTIO_VERSION"; exit 1; }
start=$(date +%s)
istioctl --context "$CLUSTER" install -f istio/install.yaml -y
k rollout status deployment/istiod -n istio-system --timeout=5m
k apply -f kubernetes/namespace.yaml
k apply -n "$NS" -f kubernetes/bookinfo.yaml
k apply -n "$NS" -f istio/gateway.yaml -f istio/virtual-service.yaml -f istio/telemetry.yaml
for d in details-v1 ratings-v1 reviews-v1 reviews-v2 reviews-v3 productpage-v1; do
  k rollout status "deployment/$d" -n "$NS" --timeout=5m
done
k apply -f monitoring/prometheus/prometheus.yaml
k rollout status deployment/prometheus -n istio-system --timeout=5m
k apply -f monitoring/kiali/kiali.yaml
k rollout status deployment/kiali -n istio-system --timeout=5m
k apply -f monitoring/kiali/kiali-lb.yaml
istioctl --context "$CLUSTER" analyze -n "$NS"
k get pods -n "$NS"
k get pods -n "$NS" -o json | python -c 'import json,sys; pods=json.load(sys.stdin)["items"]; assert len(pods)==6 and all(len(p["spec"]["containers"])==2 and all(c["ready"] for c in p["status"].get("containerStatuses",[])) and len(p["status"].get("containerStatuses",[]))==2 for p in pods), "Se requieren seis pods 2/2"'
k get svc -n istio-system
mkdir -p .local
printf 'deployment_seconds %s\n' "$(( $(date +%s)-start ))" > .local/deployment-metrics.txt
