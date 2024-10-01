#!/bin/bash

source "cloudflare-sdk.sh"

read_records() {
    IFS=' ' read -r -a subdomains <<<"${1//,/ }"
    for subdomain in "${subdomains[@]}"; do
        [[ "$subdomain" == "@" ]] && name="$ZONE" || name="$subdomain.$ZONE"
        records+=("$name $2 $3 $4")
    done
}

find_similar() {
    jq -r "map(select(
        .name==\"$1\" and
        .content==\"$2\" and
        .type==\"$3\" and
        .proxied==$4
        )) | .[0].id // empty
    " <<<"$current_records"
}

find_invalids() {
    jq -r "
        map(select(
            (.name==\"$1\" and .type==\"CNAME\") or
            (.name==\"$1\" and .type==\"$3\" and .id!=\"$5\")
        )) | .[].id // empty
    " <<<"$current_records"
}

zone_id="$1"
current_records="$(get_dns_records "$zone_id")"
error=0

declare -a records

if [[ -n "$RECORDS_IPV4_DIRECT" || -n "$RECORDS_IPV4_PROXY" ]]; then
    ipv4="${IPV4_OVERRIDE:-"$(curl -Ss4 ip.sb)"}"
    if [[ -n "$ipv4" ]]; then
        read_records "$RECORDS_IPV4_DIRECT" "$ipv4" "A" "false"
        read_records "$RECORDS_IPV4_PROXY" "$ipv4" "A" "true"
    else
        echo "Could not obtain ipv4. Skipping ipv4 records."
        error=1
    fi
fi

if [[ -n "$RECORDS_IPV6_DIRECT" || -n "$RECORDS_IPV6_PROXY" ]]; then
    ipv6="${IPV6_OVERRIDE:-"$(curl -Ss6 ip.sb)"}"
    if [[ -n "$ipv6" ]]; then
        read_records "$RECORDS_IPV6_DIRECT" "$ipv6" "AAAA" "false"
        read_records "$RECORDS_IPV6_PROXY" "$ipv6" "AAAA" "true"
    else
        echo "Could not obtain ipv6. Skipping ipv6 records."
        error=1
    fi
fi

for record in "${records[@]}"; do

    read -r -a args <<<"$record"
    name="${args[0]}"

    duplicate_id="$(find_similar "${args[@]}")"
    invalid_ids="$(find_invalids "${args[@]}" "$duplicate_id")"

    while IFS='' read -r id && [[ -n "$id" ]]; do

        if delete_dns_record "$zone_id" "$id" >/dev/null; then
            echo "Invalid DNS record $id deleted."
        else
            echo "Error deleting invalid DNS record: $id"
            error=1
        fi

    done <<<"$invalid_ids"

    if [[ -n "$duplicate_id" ]]; then
        echo "DNS record for $name seems OK."
    else
        if create_dns_record "$zone_id" "${args[@]}" \
            "Created by freiheit-cloudflare" >/dev/null; then
            echo "New DNS record created for $name"
        else
            echo "Error creating new DNS record for $name"
            error=1
        fi
    fi

done

exit "$error"
