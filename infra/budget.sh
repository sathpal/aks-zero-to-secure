#!/usr/bin/env bash
# Email alerts when this subscription's cost this month reaches 50% and 80% of a monthly budget, or is
# forecast to pass 100%. A budget only alerts; it never stops anything. Deleting resources is what saves money.
# Usage: ./infra/budget.sh <amount-in-your-billing-currency> <email>
#   e.g. ./infra/budget.sh 1500 you@example.com      (1500 = INR 1,500 if your subscription bills in INR)
# If your subscription type doesn't support budgets, set one in the portal: Cost Management > Budgets.
# shellcheck source-path=SCRIPTDIR source=env.sh
. "$(dirname "$0")/env.sh"; need az
AMOUNT=${1:?usage: budget.sh <amount> <email>}; EMAIL=${2:?usage: budget.sh <amount> <email>}
[[ "$AMOUNT" =~ ^[0-9]+$ ]] || { echo "amount must be a whole number, got: $AMOUNT"; exit 1; }
SUB=$(az account show --query id -o tsv)
START=$(date -u +%Y-%m-01)

note() { printf '"%s":{"enabled":true,"operator":"GreaterThanOrEqualTo","threshold":%s,"thresholdType":"%s","contactEmails":["%s"]}' "$1" "$2" "$3" "$EMAIL"; }
BODY=$(printf '{"properties":{"category":"Cost","amount":%s,"timeGrain":"Monthly","timePeriod":{"startDate":"%sT00:00:00Z"},"notifications":{%s,%s,%s}}}' \
  "$AMOUNT" "$START" "$(note actual50 50 Actual)" "$(note actual80 80 Actual)" "$(note forecast100 100 Forecasted)")

az rest --method put -o none \
  --url "https://management.azure.com/subscriptions/$SUB/providers/Microsoft.Consumption/budgets/aks-zero-to-secure?api-version=2023-05-01" \
  --body "$BODY"
say "budget 'aks-zero-to-secure' set: $AMOUNT per month on $(az account show --query name -o tsv); alerts go to $EMAIL"
