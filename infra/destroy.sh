#!/usr/bin/env bash
# Delete everything the course created: the resource group holds the registry and both clusters, and
# deleting an AKS cluster also deletes its node resource group (MC_...). Waits until Azure confirms,
# so you can recreate straight away. NO_WAIT=1 returns immediately instead.
# shellcheck source-path=SCRIPTDIR source=env.sh
. "$(dirname "$0")/env.sh"; need az
az group show -n "$RG" -o none 2>/dev/null || { echo "resource group $RG doesn't exist: nothing to delete"; exit 0; }
say "resources in $RG"
az resource list -g "$RG" --query "[].{name:name, type:type}" -o table
read -r -p "Delete resource group $RG and everything in it? [y/N] " a; [ "$a" = y ] || exit 1
if [ "${NO_WAIT:-}" = 1 ]; then
  az group delete -n "$RG" --yes --no-wait && echo "deleting $RG in the background"
else
  echo "deleting $RG (about 5-10 minutes)..."; az group delete -n "$RG" --yes && echo "deleted $RG"
fi
kubectl config delete-context "$AKS" >/dev/null 2>&1 || true
kubectl config delete-context "${AUTO:-aks-z2s-auto}" >/dev/null 2>&1 || true
