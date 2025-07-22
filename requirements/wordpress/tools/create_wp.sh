#!/bin/bash
set -e

echo "⏳ Waiting for MariaDB ($MYSQL_HOSTNAME) to be ready..."

# More reliable DB connection check
until mysqladmin ping -h"$MYSQL_HOSTNAME" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" --silent; do
  echo "⏳ Still waiting for MariaDB..."
  sleep 2
done

echo "✅ MariaDB is up!"

# Install WordPress if not installed
if [ ! -f /var/www/html/wp-config.php ]; then
    echo "📦 Downloading WordPress..."
    wp core download --path=/var/www/html --allow-root

    echo "⚙️ Creating wp-config.php..."
    wp config create \
      --dbname="$MYSQL_DATABASE" \
      --dbuser="$MYSQL_USER" \
      --dbpass="$MYSQL_PASSWORD" \
      --dbhost="$MYSQL_HOSTNAME" \
      --allow-root

    echo "🛠 Installing WordPress..."
    wp core install \
      --url="https://${DOMAIN_NAME}" \
      --title="My Site" \
      --admin_user="$MYSQL_USER" \
      --admin_password="$MYSQL_ROOT_PASSWORD" \
      --admin_email="$WP_ADMIN_EMAIL" \
      --allow-root

    echo "👤 Creating second WordPress user..."
    wp user create \
      "$WP_SECOND_USER" "$WP_SECOND_EMAIL" \
      --user_pass="$WP_SECOND_PASS" \
      --role=subscriber \
      --allow-root
else
    echo "✅ WordPress already installed"
fi

# Set correct permissions
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# Start PHP-FPM
exec /usr/sbin/php-fpm8.2 -F