FROM debian:bookworm-backports

RUN apt-get update && apt-get install -y \
    php php-mysql php-mbstring php-xml php-zip mariadb-client \
    curl \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/www/html \
    && curl -L https://github.com/vrana/adminer/releases/download/v5.4.1/adminer-5.4.1-en.php -o /var/www/html/index.php

EXPOSE 8080

CMD ["php", "-S", "0.0.0.0:8080", "-t", "/var/www/html"]
