#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
for cmd in aws kubectl eksctl istioctl git python; do require "$cmd"; done
aws --version
kubectl version --client
eksctl version
istioctl version --remote=false
aws sts get-caller-identity --query Arn --output text
aws iam get-role --role-name LabRole --query Role.Arn --output text
aws eks list-clusters --region "$REGION"
aws eks describe-addon-versions --addon-name "$ADDON" --kubernetes-version "$K8S_VERSION" --region "$REGION" --query 'addons[0].addonVersions[0].addonVersion' --output text
