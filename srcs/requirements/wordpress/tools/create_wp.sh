#!/bin/sh
set -e

echo "⏳ Waiting for MariaDB ($MYSQL_HOSTNAME) to be ready..."

MYSQL_PASSWORD=$(cat /run/secrets/db_password)
WP_SECOND_PASS=$(cat /run/secrets/wp_second_password)
REDIS_PASSWORD=$(cat /run/secrets/redis_password)

# Wait for MariaDB to be fully ready (up to 60 seconds)
for i in $(seq 1 30); do
    if mysqladmin ping -h"$MYSQL_HOSTNAME" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" --silent; then
        if mysql -h"$MYSQL_HOSTNAME" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "SHOW DATABASES;" >/dev/null 2>&1; then
            echo "✅ MariaDB is fully up and accessible!"
            break
        fi
    fi
    echo "⏳ Still waiting for MariaDB ($i/30)..."
    sleep 2
done

if ! mysqladmin ping -h"$MYSQL_HOSTNAME" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" --silent; then
    echo "❌ MariaDB is not ready after 60 seconds"
    exit 1
fi

# Install WordPress if not installed
if [ ! -f /var/www/html/wp-config.php ]; then
    echo "📦 Downloading WordPress..."
    wp core download --path=/var/www/html --allow-root --force

    echo "⚙️ Creating wp-config.php..."
    wp config create \
        --dbname="$MYSQL_DATABASE" \
        --dbuser="$MYSQL_USER" \
        --dbpass="$MYSQL_PASSWORD" \
        --dbhost="$MYSQL_HOSTNAME" \
        --allow-root --force

    echo "🛠 Installing WordPress..."
    wp core install \
        --url="https://${DOMAIN_NAME}" \
        --title="Inception-42" \
        --admin_user="$MYSQL_USER" \
        --admin_password="$(cat /run/secrets/db_root_password)" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --skip-email \
        --allow-root

    echo "👤 Creating or updating second WordPress user..."
    if wp user get "$WP_SECOND_USER" --allow-root >/dev/null 2>&1; then
        wp user update "$WP_SECOND_USER" \
            --user_pass="$WP_SECOND_PASS" \
            --user_email="$WP_SECOND_EMAIL" \
            --role=subscriber \
            --allow-root
        echo "✅ Updated existing WordPress user '$WP_SECOND_USER'"
    else
        wp user create \
            "$WP_SECOND_USER" "$WP_SECOND_EMAIL" \
            --user_pass="$WP_SECOND_PASS" \
            --role=subscriber \
            --allow-root
        echo "✅ Created WordPress user '$WP_SECOND_USER'"
    fi
else
    echo "✅ WordPress already installed"
fi

# Set correct permissions
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# redis
echo "🔧 Configuring Redis..."
if ping -c 1 redis >/dev/null 2>&1; then
    wp config set WP_REDIS_HOST redis --allow-root
    wp config set WP_REDIS_PORT 6379 --raw --allow-root
    wp config set WP_CACHE_KEY_SALT $DOMAIN_NAME --allow-root
    wp config set WP_REDIS_PASSWORD $REDIS_PASSWORD --allow-root
    wp config set WP_REDIS_CLIENT predis --allow-root
    wp plugin install redis-cache --activate --allow-root
    wp plugin update --all --allow-root
    wp redis enable --allow-root || echo "⚠️ Failed to enable Redis Object Cache, continuing..."
fi
echo "✅ Redis is up"

# Start PHP-FPM
echo "🚀 Starting PHP-FPM..."
exec /usr/sbin/php-fpm8.2 -F