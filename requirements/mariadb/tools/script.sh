#!/bin/bash

set -e

echo "💡 Running initialization script..."

# Wait until MariaDB is ready to accept connections
until mysqladmin ping --silent; do
  echo "⏳ Waiting for MariaDB to be ready..."
  sleep 2
done

# If DB already exists, skip setup
if mysql -uroot -e "USE $MYSQL_DATABASE;" 2>/dev/null; then
  echo "✅ Database $MYSQL_DATABASE already exists. Skipping setup."
else
  echo "🛠 Creating database and user..."

  mysql -uroot -e "CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE;"
  mysql -uroot -e "CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';"
  mysql -uroot -e "GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';"
  mysql -uroot -e "FLUSH PRIVILEGES;"

  echo "📦 Importing initial data from wordpress.sql..."
  mysql -uroot $MYSQL_DATABASE < /docker-entrypoint-initdb.d/wordpress.sql
fi

echo "✅ Initialization complete!"
