#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
require aws; require eksctl; require kubectl
role=$(aws iam get-role --role-name LabRole --query Role.Arn --output text)
[[ "$role" == arn:aws:iam::*:role/* ]] || { echo 'ARN inválido'; exit 1; }
mkdir -p .local
sed "s|__LAB_ROLE_ARN__|$role|g" infrastructure/eks-cluster.yaml > .local/eks-cluster.yaml
read -r -p 'Crear EKS y dos nodos genera costos. Escribe CREAR: ' answer
[[ "$answer" == CREAR ]] || exit 1
eksctl create cluster -f .local/eks-cluster.yaml
connect
k wait --for=condition=Ready nodes --all --timeout=10m
