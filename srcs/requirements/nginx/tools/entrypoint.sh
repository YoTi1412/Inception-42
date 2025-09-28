#!/bin/bash

if [ ! -f /etc/nginx/ssl/yrafai.crt ]; then
    certtool --generate-privkey --key-type rsa --bits 3072 --outfile /etc/nginx/ssl/yrafai.key

    echo "cn = $DOMAIN_NAME \
          dns_name = $DOMAIN_NAME \
          expiration_days = 365 \
          tls_www_server \
          signing_key \
          encryption_key" > /tmp/cert_template.txt

    certtool --generate-self-signed --load-privkey /etc/nginx/ssl/yrafai.key --template /tmp/cert_template.txt --outfile /etc/nginx/ssl/yrafai.crt

    rm -f /tmp/cert_template.txt

    chmod 600 /etc/nginx/ssl/yrafai.key /etc/nginx/ssl/yrafai.crt
fi

exec nginx -g "daemon off;"