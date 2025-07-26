FROM debian:bookworm-backports

# Install PHP and dependencies
RUN apt-get update && apt-get -y install \
    wget curl bash \
    php php-cli php-cgi php-mysql \
    php-fpm php-pdo php-gd php-mbstring \
    mariadb-client \
    redis \
	php-redis \
    && rm -rf /var/lib/apt/lists/*

# Install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp

# Copy PHP-FPM pool config
COPY ./conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

# Create PHP run dir
RUN mkdir -p /run/php

# Copy and prepare WordPress install script
COPY ./tools/create_wp.sh /usr/local/bin/create_wp.sh
RUN chmod +x /usr/local/bin/create_wp.sh

WORKDIR /var/www/html

ENTRYPOINT ["/usr/local/bin/create_wp.sh"]

EXPOSE 9000
