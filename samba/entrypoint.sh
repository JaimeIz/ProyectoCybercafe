#!/bin/sh -e

if [ -z "$NETBIOS_NAME" ]; then
  NETBIOS_NAME=$(hostname -s | tr [a-z] [A-Z])
else
  NETBIOS_NAME=$(echo $NETBIOS_NAME | tr [a-z] [A-Z])
fi

REALM=$(echo "$REALM" | tr [a-z] [A-Z])
DOMAIN=$(echo "$REALM" | tr [A-Z] [a-z]) 
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
  ADMIN_PASSWORD=$(cat /run/secrets/$ADMIN_PASSWORD_SECRET)

  rm -f /etc/samba/smb.conf /etc/krb5.conf

  if [ "$BIND_INTERFACES_ONLY" == yes ]; then
    INTERFACE_OPTS="--option=\"bind interfaces only=yes\" --option=\"interfaces=$INTERFACES\""
  fi
  
  PROVISION_OPTS="--server-role=dc --use-rfc2307 --domain=$WORKGROUP --realm=$REALM --adminpass='$ADMIN_PASSWORD'"

  # This step is required for INTERFACE_OPTS to work as expected
  echo "samba-tool domain $DOMAIN_ACTION $PROVISION_OPTS $INTERFACE_OPTS --dns-backend=BIND9_DLZ" | sh

  mv /etc/samba/smb.conf /etc/samba/smb.conf.bak
  echo 'root = administrator' > /etc/samba/smbusers

fi

## Setup samba certs
CERTS_DIR="/var/lib/samba/private/tls"

rm -rf $CERTS_DIR
mkdir -p -m 755 $CERTS_DIR

cp /certs/server.key $CERTS_DIR
cp /certs/server.crt $CERTS_DIR
cp /certs/ca.crt $CERTS_DIR

chown -R root:root $CERTS_DIR
chmod -R 644 $CERTS_DIR
chmod -R 600 $CERTS_DIR/server.key

#openssl req -nodes -x509 -newkey rsa:2048 -keyout $CERTS_DIR/ca.key -out $CERTS_DIR/ca.crt -subj "/C=ES/ST=HUESCA/L=HUESCA/O=Dis/CN=$REALM"
#openssl req -nodes -newkey rsa:2048 -keyout $CERTS_DIR/server.key -out $CERTS_DIR/server.scr  -subj "/C=ES/ST=HUESCA/L=HUESCA/O=Dis/CN=$HOST.$REALM"
#openssl x509 -req -in $CERTS_DIR/server.scr -days 365 -CA $CERTS_DIR/ca.crt -CAkey $CERTS_DIR/ca.key -CAcreateserial -out $CERTS_DIR/server.crt

## Setup samba configuration
rm -f /etc/samba/smb.conf /etc/krb5.conf
mkdir -p -m 744 /etc/samba/conf.d

. /root/smb.templates
echo "$KRB5CONF" > /etc/krb5.conf
echo "$SMBCONF" > /etc/samba/smb.conf
echo "$NETLOGON" > /etc/samba/conf.d/netlogon.conf
echo "$SYSVOL" > /etc/samba/conf.d/sysvol.conf

for file in $(ls -A /etc/samba/conf.d/*.conf); do
  echo "include = $file" >> /etc/samba/smb.conf
done

## Setup bind configuration
cp -r /root/bind /etc
cp -r /root/named /var
    
chown -R bind:bind /etc/bind
chmod -R 700 /etc/bind

chown -R bind:bind /var/named
chmod -R 740 /var/named

## Setup zones
# samba-tool dns zonecreate "$HOSTNAME" 148.119.10.in-addr.arpa -U administrator --password="$ADMIN_PASSWORD"
# samba-tool dns add $HOSTNAME $DOMAIN mail A 10.119.148.204 -U administrator --password=$ADMIN_PASSWORD

/usr/bin/supervisord -c /etc/supervisor/supervisord.conf