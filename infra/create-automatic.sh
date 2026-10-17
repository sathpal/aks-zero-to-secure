#!/usr/bin/env bash
# Instructor demo for session 2: an AKS Automatic cluster next to the Standard one, to compare what each
# decides for you. Learners watch; they don't need to run it.
# Needs 16 vCPUs of quota in one D-family in the region, and takes 20 to 35 minutes: start it before the session.
# Costs about US$0.16/hour for the hosted control plane plus the node VMs it provisions. Delete it the same day.
# shellcheck source-path=SCRIPTDIR source=env.sh
. "$(dirname "$0")/env.sh"; need az kubectl kubelogin
AUTO=${AUTO:-aks-z2s-auto}
save_env

say "subscription: $(az account show --query name -o tsv)   region: $LOC"
register Microsoft.ContainerService Microsoft.Compute Microsoft.Network
az group create -n "$RG" -l "$LOC" --tags course=aks-zero-to-secure -o none

say "AKS Automatic cluster $AUTO (20-35 minutes)"
az aks show -g "$RG" -n "$AUTO" -o none 2>/dev/null || \
  az aks create -g "$RG" -n "$AUTO" -l "$LOC" --sku automatic --no-ssh-key --tags course=aks-zero-to-secure -o none

say "what Automatic chose for you"
az aks show -g "$RG" -n "$AUTO" --query "{sku:sku.name, tier:sku.tier, kubernetes:currentKubernetesVersion,
  nodeProvisioning:nodeProvisioningProfile.mode, network:networkProfile.networkPluginMode,
  dataplane:networkProfile.networkDataplane, entraId:aadProfile.managed, azureRbac:aadProfile.enableAzureRbac,
  localAccountsDisabled:disableLocalAccounts, upgradeChannel:autoUpgradeProfile.upgradeChannel}" -o yaml

say "Automatic disables local accounts: grant yourself cluster admin through Azure RBAC, then sign in with Entra ID"
ME=$(az ad signed-in-user show --query id -o tsv)
AUTO_ID=$(az aks show -g "$RG" -n "$AUTO" --query id -o tsv)
az role assignment create --assignee-object-id "$ME" --assignee-principal-type User \
  --role "Azure Kubernetes Service RBAC Cluster Admin" --scope "$AUTO_ID" -o none 2>/dev/null || true
az aks get-credentials -g "$RG" -n "$AUTO" --context "$AUTO" --overwrite-existing -o none
kubelogin convert-kubeconfig -l azurecli
echo "Role assignments can take a minute or two to apply. Then:  kubectl --context $AUTO get nodes"
