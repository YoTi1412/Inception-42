#!/bin/bash

if [ ! -f /etc/nginx/ssl/yoti.crt ]; then
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/yoti.key \
        -out /etc/nginx/ssl/yoti.crt \
        -subj "/C=US/ST=State/L=City/O=Organization/OU=Unit/CN=yoti.42.fr"
fi

exec nginx -g "daemon off;"