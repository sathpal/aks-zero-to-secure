#!/usr/bin/env bash
# Session 1 cleanup: delete the local kind cluster and the two images. Nothing in Azure to delete.
set -uo pipefail
kind delete cluster --name aks101
docker rm -f pay 2>/dev/null
docker rmi payments-api:naive payments-api:1.0 payments-api:1.1 2>/dev/null
echo "session 1 cleaned up"
