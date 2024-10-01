#!/bin/bash

source "cloudflare-sdk.sh"

if [[ -z "$CLOUDFLARE_EMAIL" ]]; then
    echo "Missing environment variable: CLOUDFLARE_EMAIL"
    exit 1
fi

if [[ -z "$CLOUDFLARE_KEY" ]]; then
    echo "Missing environment variable: CLOUDFLARE_KEY"
    exit 1
fi

if [[ -z "$ZONE" ]]; then
    echo "Missing environment variable: ZONE"
    exit 1
fi

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

if [[ "$error" == "0" ]]; then
    echo "Everything is OK."
else
    echo "Something went wrong."
fi

exit "$error"
