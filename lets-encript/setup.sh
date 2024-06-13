#!/bin/sh -e

if [[ ! -f "/acme.sh/${Domain}_ecc/${Domain}.cer" ]]; then
    acme.sh --register-account -m $Mail
    acme.sh --issue --dns dns_duckdns -d $Domain
fi

if [[ ! -d '/certs' ]]; then
    mkdir /certs
fi

if [[ ! -f '/certs/server.cer' ]]; then
    cp /acme.sh/${Domain}_ecc/${Domain}.cer /certs/server.cer
    cp /acme.sh/${Domain}_ecc/${Domain}.cer /certs/server.key
fi

exec crond -n -s -m off
