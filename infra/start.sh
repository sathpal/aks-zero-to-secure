#!/usr/bin/env bash
# Resume the course cluster after ./infra/stop.sh, then refresh the kubeconfig.
# shellcheck source-path=SCRIPTDIR source=env.sh
. "$(dirname "$0")/env.sh"; need az kubectl
say "starting $AKS (a few minutes)"; az aks start -g "$RG" -n "$AKS" -o none
az aks get-credentials -g "$RG" -n "$AKS" --overwrite-existing -o none
kubectl get nodes
