#!/bin/bash

source "cloudflare-sdk.sh"

zone_id="$(get_zone_id "$ZONE")"
error=0

if [[ -n "$zone_id" ]]; then
    /usr/bin/process-zone-settings.sh "$zone_id" || error=1
    /usr/bin/process-subdomains.sh "$zone_id" || error=1
else
    echo "Unable to get zone with name $ZONE"
    error=1
fi

/usr/bin/process-worker.sh || error=1

echo "$error" >"$OUTPUT_FILE"
exit "$error"
