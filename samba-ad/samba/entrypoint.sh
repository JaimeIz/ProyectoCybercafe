#!/bin/sh -e

if [ -z "$NETBIOS_NAME" ]; then
  NETBIOS_NAME=$(hostname -s | tr [a-z] [A-Z])
else
  NETBIOS_NAME=$(echo $NETBIOS_NAME | tr [a-z] [A-Z])
fi

REALM=$(echo "$REALM" | tr [a-z] [A-Z])
WORKGROUP=$(echo "$WORKGROUP" | tr [a-z] [A-Z])
ALLOW_LDAP_INSECURE=$(echo "$ALLOW_LDAP_INSECURE" | tr [A-Z] [a-z])

if [ "$ALLOW_LDAP_INSECURE" != "true" ]; then
  ALLOW_LDAP_INSECURE=''
fi

if [ ! -f /etc/timezone ] && [ ! -z "$TZ" ]; then
  echo 'Set timezone'
  cp /usr/share/zoneinfo/$TZ /etc/localtime
  echo $TZ >/etc/timezone
fi


if [ ! -f /var/lib/samba/registry.tdb ]; then
  if [ ! -f /run/secrets/$ADMIN_PASSWORD_SECRET ]; then
    echo 'Cannot read secret $ADMIN_PASSWORD_SECRET in /run/secrets'
    exit 1
  fi

  rm -f /etc/samba/smb.conf /etc/krb5.conf

  ADMIN_PASSWORD=$(cat /run/secrets/$ADMIN_PASSWORD_SECRET)
  if [ "$BIND_INTERFACES_ONLY" == yes ]; then
    INTERFACE_OPTS="--option=\"bind interfaces only=yes\" --option=\"interfaces=$INTERFACES\""
  fi
  
  PROVISION_OPTS="--server-role=dc --use-rfc2307 --domain=$WORKGROUP --realm=$REALM --adminpass='$ADMIN_PASSWORD'"

  # This step is required for INTERFACE_OPTS to work as expected
  echo "samba-tool domain $DOMAIN_ACTION $PROVISION_OPTS $INTERFACE_OPTS --dns-backend=SAMBA_INTERNAL" | sh

  mv /etc/samba/smb.conf /etc/samba/smb.conf.bak
  echo 'root = administrator' > /etc/samba/smbusers

fi

mkdir -p -m 700 /etc/samba/conf.d

CERTS_DIR="/var/lib/samba/private/tls"
mkdir -p -m 700 $CERTS_DIR

#openssl req -nodes -x509 -newkey rsa:2048 -keyout $CERTS_DIR/ca.key -out $CERTS_DIR/ca.crt -subj "/C=ES/ST=HUESCA/L=HUESCA/O=Dis/CN=$REALM"
#openssl req -nodes -newkey rsa:2048 -keyout $CERTS_DIR/server.key -out $CERTS_DIR/server.scr  -subj "/C=ES/ST=HUESCA/L=HUESCA/O=Dis/CN=$HOST.$REALM"
#openssl x509 -req -in $CERTS_DIR/server.scr -days 365 -CA $CERTS_DIR/ca.crt -CAkey $CERTS_DIR/ca.key -CAcreateserial -out $CERTS_DIR/server.crt

rm -f /etc/samba/smb.conf /etc/krb5.conf

source /root/.templates
echo "$SMBCONF" > /etc/samba/smb.conf
echo "$NETLOGON" > /etc/samba/conf.d/netlogon.conf
echo "$SYSVOL" > /etc/samba/conf.d/sysvol.conf
echo "$KRB5CONF" > /etc/krb5.conf

for file in $(ls -A /etc/samba/conf.d/*.conf); do
  echo "include = $file" >> /etc/samba/smb.conf
done

exec samba --model=$MODEL -i </dev/null
