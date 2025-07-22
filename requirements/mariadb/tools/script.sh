#!/bin/bash
set -e
set -x 

echo "💡 Running initialization script..."

until mysqladmin ping -uroot -p"$MYSQL_ROOT_PASSWORD" --silent; do
  echo "⏳ Waiting for MariaDB to be ready..."
  sleep 2
done

# If DB already exists, skip setup
if mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "USE $MYSQL_DATABASE;" 2>/dev/null; then
  echo "✅ Database $MYSQL_DATABASE already exists. Skipping setup."
else
  echo "🛠 Creating database and user..."
  mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE;" || { echo "Failed to create database"; exit 1; }
  mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';" || { echo "Failed to create user"; exit 1; }
  mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';" || { echo "Failed to grant privileges"; exit 1; }
  mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "FLUSH PRIVILEGES;" || { echo "Failed to flush privileges"; exit 1; }
  if [ -f /docker-entrypoint-initdb.d/wordpress.sql ]; then
    echo "📦 Importing initial data from wordpress.sql..."
    mysql -uroot -p"$MYSQL_ROOT_PASSWORD" $MYSQL_DATABASE < /docker-entrypoint-initdb.d/wordpress.sql || { echo "Failed to import wordpress.sql"; exit 1; }
  else
    echo "⚠️ wordpress.sql not found, skipping import."
  fi
fi

echo "✅ Initialization complete!"