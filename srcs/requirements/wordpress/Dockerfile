FROM debian:bookworm-backports

# Install PHP, MariaDB client, Redis, and dependencies
RUN apt-get update && apt-get install -y \
    curl \
    mariadb-client \
    php php-fpm php-mysql php-redis php-cli php-mbstring php-gd \
    redis-tools \
    iputils-ping \
    && rm -rf /var/lib/apt/lists/*

# Install WP-CLI
RUN curl -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x /usr/local/bin/wp

# Copy PHP-FPM pool config
COPY ./conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

# WordPress setup script
COPY ./tools/create_wp.sh /usr/local/bin/create_wp.sh
RUN chmod +x /usr/local/bin/create_wp.sh

WORKDIR /var/www/html

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/create_wp.sh"]