#!/bin/bash

source "cloudflare-sdk.sh"

if [[ -z "$WORKER_NAME" ]]; then
    exit 0
fi

if [[ -z "$WORKER_SUBDOMAIN" ]]; then
    echo "Missing environment variable: WORKER_SUBDOMAIN"
    exit 1
fi

account_id="$3"
current_script="$(get_worker_script "$account_id" "$WORKER_NAME")"
correct_script="$(envsubst <"$WORKER_TEMPLATE")"
error=0

if [[ -z "$current_script" ]]; then

    if set_worker_script "$account_id" "$WORKER_NAME" \
        "$correct_script" >/dev/null; then
        echo "New worker created"
    else
        echo "Error creating worker"
        error=1
    fi

elif [[ "$current_script" != "$correct_script" ]]; then

    if set_worker_script "$account_id" "$WORKER_NAME" \
        "$correct_script" >/dev/null; then
        echo "Worker script updated."
    else
        echo "Error updating script."
        error=1
    fi

else
    echo "Current worker script seems OK."
fi

subdomain="$(get_worker_subdomain "$account_id")" &&
    echo "Worker path is: $WORKER_NAME.$subdomain.workers.dev" ||
    echo "Error fetching worker path."

enabled="$(get_worker_enabled "$account_id" "$WORKER_NAME")"
if [[ "$enabled" == "true" ]]; then
    echo "Worker is already enabled."
else
    if set_worker_enabled "$account_id" "$WORKER_NAME" "true" >/dev/null; then
        echo "Worker got enabled."
    else
        echo "Error enabling worker."
        error=1
    fi
fi

exit "$error"
