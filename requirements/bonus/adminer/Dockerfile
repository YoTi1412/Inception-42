FROM debian:bookworm-backports

# Install PHP, Adminer dependencies, and curl
RUN apt-get update && apt-get install -y \
    php php-mysql php-mbstring php-xml php-zip \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Download and set up Adminer
RUN mkdir -p /var/www/html \
    && curl -L https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php -o /var/www/html/index.php

# Expose port for Adminer
EXPOSE 8080

# Run PHP's built-in server for Adminer
CMD ["php", "-S", "0.0.0.0:8080", "-t", "/var/www/html"]