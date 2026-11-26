#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
connect
version=$(aws eks describe-addon-versions --addon-name "$ADDON" --kubernetes-version "$K8S_VERSION" --region "$REGION" --query 'addons[0].addonVersions[0].addonVersion' --output text)
[[ "$version" == v* ]] || { echo 'No hay versión compatible'; exit 1; }
read -r -p "Instalar CloudWatch $version genera costos. Escribe SI: " answer
[[ "$answer" == SI ]] || exit 1
# Reutiliza los permisos del rol de los nodos; no crea roles IAM.
aws eks create-addon --cluster-name "$CLUSTER" --addon-name "$ADDON" --addon-version "$version" --region "$REGION"
aws eks wait addon-active --cluster-name "$CLUSTER" --addon-name "$ADDON" --region "$REGION"
k get pods -n amazon-cloudwatch
aws eks describe-addon --cluster-name "$CLUSTER" --addon-name "$ADDON" --region "$REGION" --query 'addon.{version:addonVersion,status:status,health:health}'
