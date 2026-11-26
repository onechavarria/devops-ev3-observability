#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
count=${1:-100}
[[ "$count" =~ ^[0-9]+$ ]] && (( count > 0 && count <= 1000 )) || exit 1
connect
pod=$(k get pod -n "$NS" -l app=ratings -o jsonpath='{.items[0].metadata.name}')
# Git Bash: no MSYS path conversion inside Linux containers.
MSYS_NO_PATHCONV=1 k exec -n "$NS" "$pod" -c ratings -- sh -c '
  ok=0; fail=0
  for i in $(seq 1 "$1"); do
    code=$(curl -sS --max-time 10 -o /dev/null -w "%{http_code}" http://productpage:9080/productpage) || code=000
    echo "request $i HTTP $code"
    if [ "$code" = 200 ]; then ok=$((ok+1)); else fail=$((fail+1)); fi
    sleep 1
  done
  echo "success=$ok errors=$fail"
  [ "$fail" -eq 0 ]
' sh "$count"
