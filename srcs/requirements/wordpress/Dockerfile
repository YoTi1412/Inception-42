FROM debian:bookworm-backports

RUN apt-get update && apt-get install -y \
    curl \
    mariadb-client \
    php php-fpm php-mysql php-redis php-cli php-mbstring php-gd \
    redis-tools \
    iputils-ping \
    && rm -rf /var/lib/apt/lists/*

RUN curl -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x /usr/local/bin/wp

COPY ./conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

COPY ./tools/create_wp.sh /usr/local/bin/create_wp.sh

RUN chmod +x /usr/local/bin/create_wp.sh

WORKDIR /var/www/html

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/create_wp.sh"]