#!/bin/bash

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

exec "$@"
