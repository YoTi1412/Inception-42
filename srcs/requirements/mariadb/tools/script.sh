#!/bin/bash

DATADIR="/var/lib/mysql"
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

until mysqladmin ping --silent; do
  sleep 2
done

if ! mysql -u root -e "SHOW DATABASES LIKE '$MYSQL_DATABASE';" | grep -q "$MYSQL_DATABASE"; then
  mysql -u root << EOF
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
fi

kill $MYSQLD_PID
wait $MYSQLD_PID 2>/dev/null

exec mysqld --user=mysql --datadir="$DATADIR" --bind-address=0.0.0.0
