FROM debian:bookworm-backports

RUN mkdir -p /var/www/html/public

COPY index.html /var/www/html/public/index.html
COPY assets /var/www/html/public/assets

RUN chown -R www-data:www-data /var/www/html/public && \
    chmod -R 755 /var/www/html/public

CMD ["true"]
