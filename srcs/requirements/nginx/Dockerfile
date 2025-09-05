FROM debian:bookworm-backports

RUN apt-get update && apt-get install -y nginx gnutls-bin procps \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/nginx/ssl /run/nginx /var/www/html

COPY ./conf/nginx.conf /etc/nginx/conf.d/default.conf
COPY ./tools/entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

EXPOSE 443

ENTRYPOINT ["/entrypoint.sh"]
