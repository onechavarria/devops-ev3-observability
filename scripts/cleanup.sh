#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
read -r -p "Eliminar el clúster $CLUSTER y sus recursos. Escribe ELIMINAR: " answer
[[ "$answer" == ELIMINAR ]] || exit 1
connect
# Borrar primero los balanceadores y esperar la eliminación del Service.
k delete -f monitoring/kiali/kiali-lb.yaml --ignore-not-found --wait=true --timeout=10m
k delete namespace "$NS" --ignore-not-found --wait=true --timeout=5m
addons=$(aws eks list-addons --cluster-name "$CLUSTER" --region "$REGION" --query addons --output text)
if [[ "$addons" == *"$ADDON"* ]]; then
  aws eks delete-addon --cluster-name "$CLUSTER" --addon-name "$ADDON" --region "$REGION"
  aws eks wait addon-deleted --cluster-name "$CLUSTER" --addon-name "$ADDON" --region "$REGION"
fi
eksctl delete cluster --name "$CLUSTER" --region "$REGION" --wait
aws eks list-clusters --region "$REGION"
aws cloudformation list-stacks --region "$REGION" --query "StackSummaries[?contains(StackName, 'eksctl-devops-ev3') && StackStatus!='DELETE_COMPLETE'].[StackName,StackStatus]" --output table
aws ec2 describe-instances --region "$REGION" --filters "Name=tag:eks:cluster-name,Values=$CLUSTER" "Name=instance-state-name,Values=pending,running,stopping,stopped" --query 'Reservations[].Instances[].InstanceId'
aws logs describe-log-groups --region "$REGION" --log-group-name-prefix "/aws/containerinsights/$CLUSTER/" --query 'logGroups[].logGroupName'
echo 'Verifica también EC2 > Load Balancers, EBS y CloudWatch. Los log groups pueden persistir: elimina solo los de este clúster después de guardar evidencia.'
