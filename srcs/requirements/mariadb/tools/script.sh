#!/bin/bash

DATADIR="/var/lib/mysql"
INIT_SQL="$DATADIR/init.sql"
ROOT_PWD=$(cat /run/secrets/db_root_password)
MYSQL_PASSWORD=$(cat /run/secrets/db_password)
WP_SECOND_PASS=$(cat /run/secrets/wp_second_password)

mkdir -p /run/mysqld "$DATADIR"
chown -R mysql:mysql /run/mysqld "$DATADIR"

if [ ! -d "$DATADIR/mysql" ]; then
    mysql_install_db --user=mysql --datadir="$DATADIR"
fi

mysqld --user=mysql --datadir="$DATADIR" --bind-address=0.0.0.0 --skip-networking &
MYSQLD_PID=$!

echo "⏳ Waiting for MariaDB to start..."
until mysqladmin ping --silent; do
    echo "MariaDB not ready yet, retrying in 2 s..."
    sleep 2
done
echo "✅ MariaDB is up!"

if ! mysql -u root -e "SHOW DATABASES LIKE '$MYSQL_DATABASE';" | grep -q "$MYSQL_DATABASE"; then
    echo "📦 Creating WordPress database and users..."
    cat > "$INIT_SQL" << EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${ROOT_PWD}';
CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '${ROOT_PWD}';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
CREATE USER IF NOT EXISTS '${WP_SECOND_USER}'@'%' IDENTIFIED BY '${WP_SECOND_PASS}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
GRANT SELECT ON \`${MYSQL_DATABASE}\`.* TO '${WP_SECOND_USER}'@'%';
FLUSH PRIVILEGES;
EOF
    mysql -u root < "$INIT_SQL"
    chown mysql:mysql "$INIT_SQL"
    chmod 600 "$INIT_SQL"
    echo "✅ WordPress database and users created."
else
    echo "✅ WordPress database already exists, skipping creation."
fi

kill $MYSQLD_PID
wait $MYSQLD_PID 2>/dev/null

exec mysqld --user=mysql --datadir="$DATADIR" --bind-address=0.0.0.0
