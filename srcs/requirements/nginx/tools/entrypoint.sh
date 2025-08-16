#!/bin/bash

if [ ! -f /etc/nginx/ssl/yrafai.crt ]; then
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/yrafai.key \
        -out /etc/nginx/ssl/yrafai.crt \
        -subj "/C=US/ST=State/L=City/O=Organization/OU=Unit/CN=yrafai.42.fr"
fi

exec nginx -g "daemon off;"