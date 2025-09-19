#!/bin/sh

MYSQL_PASSWORD=$(cat /run/secrets/db_password)
WP_SECOND_PASS=$(cat /run/secrets/wp_second_password)
REDIS_PASSWORD=$(cat /run/secrets/redis_password)
ROOT_PWD=$(cat /run/secrets/db_root_password)

echo "⏳ Waiting for MariaDB ($MYSQL_HOSTNAME)..."
until mysqladmin ping -h"$MYSQL_HOSTNAME" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" --silent; do
  echo "MariaDB not ready yet, retrying in 2 s..."
  sleep 2
done

echo "✅ MariaDB is up!"

if [ ! -f /var/www/html/wp-config.php ]; then
    echo "📦 Installing WordPress..."
    wp core download --allow-root --force
    wp config create \
        --dbname="$MYSQL_DATABASE" \
        --dbuser="$MYSQL_USER" \
        --dbpass="$MYSQL_PASSWORD" \
        --dbhost="$MYSQL_HOSTNAME" \
        --allow-root --force
    wp core install \
        --url="https://${DOMAIN_NAME}" \
        --title="Inception-42" \
        --admin_user="$MYSQL_USER" \
        --admin_password="$ROOT_PWD" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --skip-email \
        --allow-root
    wp user create "$WP_SECOND_USER" "$WP_SECOND_EMAIL" \
        --user_pass="$WP_SECOND_PASS" \
        --role=subscriber \
        --allow-root || \
    wp user update "$WP_SECOND_USER" \
        --user_pass="$WP_SECOND_PASS" \
        --user_email="$WP_SECOND_EMAIL" \
        --role=subscriber \
        --allow-root
fi

echo "🔧 Configuring Redis..."
wp config set WP_REDIS_HOST redis --allow-root
wp config set WP_REDIS_PORT 6379 --raw --allow-root
wp config set WP_CACHE_KEY_SALT "$DOMAIN_NAME" --allow-root
wp config set WP_REDIS_PASSWORD "$REDIS_PASSWORD" --allow-root
wp config set WP_REDIS_CLIENT predis --allow-root
wp plugin install redis-cache --activate --allow-root
wp redis enable --allow-root || echo "⚠️ Redis failed, continuing..."

echo "🚀 Starting PHP-FPM..."
exec /usr/sbin/php-fpm8.2 -F
