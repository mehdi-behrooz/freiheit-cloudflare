#!/bin/bash

ENDPOINT="https://api.cloudflare.com/client/v4"

http() {
    content_type="${4:-"application/json"}"
    curl --silent \
        --show-error \
        --header "X-Auth-Email: $CLOUDFLARE_EMAIL" \
        --header "X-Auth-Key: $CLOUDFLARE_KEY" \
        --header "Content-Type: $content_type" \
        --request "$1" \
        --url "$2" \
        --data "${3:-''}"
}

results() {
    json=$(cat <&0)
    success=$(jq ".success" <<<"$json")
    if [[ "$success" == "true" ]]; then
        jq ".result" <<<"$json"
    else
        jq -r '.errors[]? // .
        | "Error \(.code): \(.message // .error)"' <<<"$json" >&2
        return 1
    fi
}

get() {
    http GET "${@}"
}

post() {
    http POST "${@}"
}

patch() {
    http PATCH "${@}"
}

delete() {
    http DELETE "${@}"
}

put() {
    http PUT "${@}"
}

get_zone_id() {
    url="/zones?name=$1"
    get "$ENDPOINT/$url" | results | jq -r '.[0].id // empty'
}

get_zone_setting() {
    url="/zones/$1/settings/$2"
    get "$ENDPOINT/$url" | results | jq -r '.value'
}

set_zone_setting() {
    url="/zones/$1/settings/$2"
    data="{\"value\": \"$3\"}"
    patch "$ENDPOINT/$url" "$data" | results
}

get_dns_records() {
    url="/zones/$1/dns_records"
    get "$ENDPOINT/$url" | results
}

create_dns_record() {
    url="/zones/$1/dns_records"
    body=$(
        jq <<< \
            "{
                \"name\": \"$2\",
                \"content\": \"$3\",
                \"type\": \"$4\",
                \"proxied\": $5,
                \"comment\": \"$6\"
            }"
    )
    post "$ENDPOINT/$url" "$body" | results
}

delete_dns_record() {
    url="/zones/$1/dns_records/$2"
    delete "$ENDPOINT/$url" | results
}

get_account_id() {
    url="/zones?name=$1"
    get "$ENDPOINT/$url" | results | jq -r ".[0]? .account?.id?"
}

get_worker_script() {
    url="/accounts/$1/workers/scripts/$2"
    script=$(get "$ENDPOINT/$url")
    jq <<<"$script" &>/dev/null && return 1 || echo "$script"
}

set_worker_script() {
    url="/accounts/$1/workers/scripts/$2"
    put "$ENDPOINT/$url" "$3" "application/javascript" | results
}

get_worker_subdomain() {
    url="/accounts/$1/workers/subdomain"
    get "$ENDPOINT/$url" | results | jq -r ".subdomain"
}

get_worker_enabled() {
    url="/accounts/$1/workers/services/$2/environments/production/subdomain"
    get "$ENDPOINT/$url" | results | jq -r '.enabled'
}

set_worker_enabled() {
    url="/accounts/$1/workers/services/$2/environments/production/subdomain"
    post "$ENDPOINT/$url" "{\"enabled\": $3}" | results
}
