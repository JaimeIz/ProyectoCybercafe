FROM neilpang/acme.sh

ENV DuckDNS_Token=${DuckDNS_Token} \
    Domain=example.com \
    Mail=admin@example.com

HEALTHCHECK CMD test -f /acme.sh/${Domain}_ecc/${Domain}.cer || exit 1

COPY setup.sh /

RUN chmod +x /setup.sh /acme.sh

ENTRYPOINT ["/setup.sh"]