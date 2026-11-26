#!/usr/bin/env bash
set -Eeuo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
export AWS_PAGER=""
CLUSTER=devops-ev3
REGION=us-east-1
NS=microservices-demo
K8S_VERSION=1.37
ISTIO_VERSION=1.32.0
ADDON=amazon-cloudwatch-observability
require() { command -v "$1" >/dev/null || { echo "Falta $1" >&2; exit 1; }; }
connect() {
  aws eks update-kubeconfig --name "$CLUSTER" --region "$REGION" --alias "$CLUSTER"
  kubectl --context "$CLUSTER" get nodes
}
k() { kubectl --context "$CLUSTER" "$@"; }
