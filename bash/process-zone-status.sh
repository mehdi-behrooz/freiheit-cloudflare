#!/bin/bash

status="$2"
ns1="$4"
ns2="$5"

if [[ "$status" != "active" ]]; then
    echo "Zone is not active yet." \
        "Make sure that you have set your host DNS to $ns1 and $ns2"
    exit 1
fi
