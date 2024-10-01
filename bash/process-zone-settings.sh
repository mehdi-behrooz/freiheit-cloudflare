#!/bin/bash

source "cloudflare-sdk.sh"

zone_id="$1"

declare -A settings

settings["min_tls_version"]="$MINIMUM_TLS_VERSION"

if [[ "$ALWAYS_USE_HTTPS" == "true" ]]; then
    settings["always_use_https"]=on
else
    settings["always_use_https"]=off
fi

if [[ "$SSL_MODE" == "auto" ]]; then
    settings["ssl"]="strict"
    settings["ssl_automatic_mode"]="auto"
else
    settings["ssl"]="$SSL_MODE"
    settings["ssl_automatic_mode"]="custom"
fi

error=0

readarray -t sorted \
    < <(for a in "${!settings[@]}"; do echo "$a"; done | sort)

for key in "${sorted[@]}"; do

    expected_value="${settings[$key]}"

    current_value="$(get_zone_setting "$zone_id" "$key")"

    if [[ "$current_value" == "$expected_value" ]]; then
        echo "Zone setting is already set: $key = $current_value"
        continue
    fi

    if set_zone_setting "$zone_id" "$key" "$expected_value" >/dev/null; then
        echo "Zone setting updated: $key = $expected_value"
    else
        echo "Error while updating zone setting $key = $expected_value"
        error=1
    fi

done

exit "$error"
