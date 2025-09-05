#!/bin/bash

if [ ! -f /etc/nginx/ssl/yoti.crt ]; then
    certtool --generate-privkey --key-type rsa --bits 3072 --outfile /etc/nginx/ssl/yoti.key

    echo "cn = $DOMAIN_NAME \
          dns_name = $DOMAIN_NAME \
          expiration_days = 365 \
          tls_www_server \
          signing_key \
          encryption_key" > /tmp/cert_template.txt

    certtool --generate-self-signed --load-privkey /etc/nginx/ssl/yoti.key --template /tmp/cert_template.txt --outfile /etc/nginx/ssl/yoti.crt

    rm -f /tmp/cert_template.txt

    chmod 600 /etc/nginx/ssl/yoti.key /etc/nginx/ssl/yoti.crt
fi

exec nginx -g "daemon off;"