#!/usr/bin/env bash
# The course cluster, used from session 2 onwards: a resource group, an Azure Container Registry and an
# AKS Standard cluster on the Free tier (no control-plane fee; you pay for node VMs, disks, load balancer, IPs).
# Network choices are fixed at creation, so it starts with Azure CNI overlay + the Cilium dataplane, which
# session 4 needs for network policy. The OIDC issuer and workload identity are on for session 9.
# Idempotent: re-running skips what already exists. Takes about 10 minutes.
# Defaults (override on the first run, e.g. NODE_SIZE=Standard_B2s ./infra/create-cluster.sh):
#   LOC=centralindia  NODE_COUNT=2  NODE_SIZE=Standard_D2s_v5 (about US$0.10/hour per node in Central India)
# shellcheck source-path=SCRIPTDIR source=env.sh
. "$(dirname "$0")/env.sh"; need az kubectl
save_env

say "subscription: $(az account show --query name -o tsv)   region: $LOC   nodes: $NODE_COUNT x $NODE_SIZE"
register Microsoft.ContainerService Microsoft.ContainerRegistry Microsoft.Compute Microsoft.Network

say "resource group $RG and container registry $ACR (Basic tier, about US\$0.17/day)"
az group create -n "$RG" -l "$LOC" --tags course=aks-zero-to-secure -o none
az acr show -n "$ACR" -o none 2>/dev/null || az acr create -g "$RG" -n "$ACR" --sku Basic -o none

say "AKS cluster $AKS (the long step)"
if ! az aks show -g "$RG" -n "$AKS" -o none 2>/dev/null; then
  az aks create -g "$RG" -n "$AKS" -l "$LOC" --tier free \
    --nodepool-name system --node-count "$NODE_COUNT" --node-vm-size "$NODE_SIZE" --os-sku AzureLinux \
    --network-plugin azure --network-plugin-mode overlay --network-dataplane cilium \
    --enable-oidc-issuer --enable-workload-identity \
    --attach-acr "$ACR" \
    --auto-upgrade-channel patch --node-os-upgrade-channel NodeImage \
    --no-ssh-key --tags course=aks-zero-to-secure -o none
fi

say "kubeconfig for $AKS"
az aks get-credentials -g "$RG" -n "$AKS" --overwrite-existing -o none
kubectl get nodes -o wide
echo
echo "Done. Names are in infra/.lab.env; load them into your shell with:  source infra/.lab.env"
echo "When you finish for the day:  ./infra/destroy.sh   (or ./infra/stop.sh to pause the nodes)"
