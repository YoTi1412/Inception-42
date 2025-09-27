FROM debian:bookworm-backports

RUN apt-get update && apt-get install -y nginx \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/nginx/ssl /run/nginx /var/www/html

COPY index.html /var/www/html/index.html
COPY assets /var/www/html/assets
COPY conf/nginx.conf /etc/nginx/conf.d/default.conf

RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
