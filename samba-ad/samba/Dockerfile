FROM alpine:3.19

ENV ADMIN_PASSWORD_SECRET=samba-admin-password \
    ALLOW_DNS_UPDATES=secure \
    ALLOW_LDAP_INSECURE=false \
    BIND_INTERFACES_ONLY=yes \
    DOMAIN_ACTION=provision \
    DOMAIN_LOGONS=yes \
    DOMAIN_MASTER=no \
    INTERFACES="lo eth0" \
    LOG_LEVEL=1 \
    MODEL=standard \
    NETBIOS_NAME= \
    REALM=ad.example.com \
    SERVER_STRING="Samba Domain Controller" \
    TZ=UTC \
    WINBIND_USE_DEFAULT_DOMAIN=yes \
    WORKGROUP=AD

COPY .templates /root/
COPY entrypoint.sh /usr/local/bin/

RUN apk add --update --no-cache \
        krb5 \
        tdb ldb-tools \
        samba-dc samba-winbind-clients \
        bind bind-libs bind-tools \ 
        libcrypto3 libxml2 tzdata \
        py3-setuptools openssl \ 
    && chmod 0755 /usr/local/bin/entrypoint.sh

VOLUME /etc/samba /var/lib/samba
EXPOSE 53 53/udp 88 88/udp 135 137-138/udp 139 389 389/udp 445 464 464/udp 636 3268-3269 49152-65535

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
