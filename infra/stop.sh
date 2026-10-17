#!/usr/bin/env bash
# Pause the course cluster between labs: node VMs stop billing, the cluster keeps its configuration.
# The registry, public IPs and any persistent disks still bill while stopped. Resume with ./infra/start.sh.
# shellcheck source-path=SCRIPTDIR source=env.sh
. "$(dirname "$0")/env.sh"; need az
say "stopping $AKS (a few minutes)"; az aks stop -g "$RG" -n "$AKS" -o none
az aks show -g "$RG" -n "$AKS" --query "{cluster:name, power:powerState.code}" -o table
