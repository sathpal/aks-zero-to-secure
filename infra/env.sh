# shellcheck shell=bash
# Shared by every infra script: names, defaults and helpers.
# The first run saves the names to infra/.lab.env (git-ignored) so later scripts and sessions reuse them.
# To start over with new names, delete infra/.lab.env after destroy.sh.
set -euo pipefail
INFRA="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENVF="$INFRA/.lab.env"
# shellcheck source=/dev/null
[ -f "$ENVF" ] && . "$ENVF"
LOC=${LOC:-centralindia}
RG=${RG:-rg-aks-z2s}
AKS=${AKS:-aks-z2s}
NODE_SIZE=${NODE_SIZE:-Standard_D2s_v5}
NODE_COUNT=${NODE_COUNT:-2}
SUFFIX=${SUFFIX:-$(openssl rand -hex 3)}
ACR=${ACR:-acrz2s$SUFFIX}

save_env() {
  printf 'LOC=%s\nRG=%s\nAKS=%s\nNODE_SIZE=%s\nNODE_COUNT=%s\nSUFFIX=%s\nACR=%s\n' \
    "$LOC" "$RG" "$AKS" "$NODE_SIZE" "$NODE_COUNT" "$SUFFIX" "$ACR" > "$ENVF"
}
say() { printf '\n== %s\n' "$*"; }
need() { for c in "$@"; do command -v "$c" >/dev/null || { echo "missing: $c (see PREREQUISITES.md)"; exit 1; }; done; }
register() { # resource providers a brand-new subscription has not registered yet
  for p in "$@"; do
    [ "$(az provider show -n "$p" --query registrationState -o tsv 2>/dev/null)" = Registered ] && continue
    echo "registering $p (first time only, can take a few minutes)"
    az provider register -n "$p" --wait -o none
  done
}
