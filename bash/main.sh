#!/bin/bash

source "cloudflare-sdk.sh"

z="$(get_zone "$ZONE")"

if [[ -z "$z" ]]; then
    echo "Unable to get zone with name $ZONE"
    exit 1
fi

query='[.id, .status, .account.id, .name_servers[]] | @tsv'
read -r -a args < <(jq -r "$query" <<<"$z")

error=0

/usr/bin/process-zone-status.sh "${args[@]}" || error=1
/usr/bin/process-zone-settings.sh "${args[@]}" || error=1
/usr/bin/process-subdomains.sh "${args[@]}" || error=1
/usr/bin/process-worker.sh "${args[@]}" || error=1

exit "$error"
