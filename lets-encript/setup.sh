#!/bin/sh -e

if [[ ! -f "/acme.sh/${Domain}_ecc/${Domain}.cer" ]]; then
    acme.sh --register-account -m $Mail
    acme.sh --issue --dns dns_duckdns -d $Domain
fi

if [[ ! -d '/certs' ]]; then
    mkdir /certs
fi

# TODO: make it so it executes this after the renewal of the certs
if [[ ! -f '/certs/server.cer' ]]; then
    cp /acme.sh/${Domain}_ecc/${Domain}.cer /certs/server.crt
    cp /acme.sh/${Domain}_ecc/${Domain}.key /certs/server.key
    cp /acme.sh/${Domain}_ecc/ca.cer /certs/ca.crt
fi

exec crond -n -s -m off
