#!/usr/bin/env bash
# Session 2 cleanup: deleting the resource group removes the cluster, its VMs, the registry and the public IP.
exec "$(dirname "$0")/../../infra/destroy.sh"
