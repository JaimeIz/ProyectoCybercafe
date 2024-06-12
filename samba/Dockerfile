FROM debian

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


RUN  apt update \
    && apt install -y \
        acl \
        ntp \
        attr \
        sssd \
        samba smbclient \ 
        winbind libnss-winbind libpam-winbind \
        ldb-tools ldap-utils \ 
        bind9 bind9utils dnsutils \
        krb5-user krb5-kdc libpam-krb5 \
        openssl ca-certificates certbot \
        pwgen expect \
        supervisor \
        rsyslog pkg-config \
        inetutils-ping \
    && apt-get clean autoclean \
    && apt-get autoremove --yes \
    && rm -rf /var/lib/{apt,dpkg,cache,log} \
    && rm -fr /tmp/* /var/tmp/*

COPY conf/smb.templates /root/
COPY entrypoint.sh /usr/local/bin/
COPY conf/bind/config /root/bind
COPY conf/bind/zones /root/named


RUN chmod 0755 /usr/local/bin/entrypoint.sh
        
VOLUME /etc/samba /var/lib/samba /var/named /etc/supervisor

EXPOSE 53 53/udp 88 88/udp 135 137-138/udp 139 389 389/udp 445 464 464/udp 636 3268-3269 49152-65535

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]