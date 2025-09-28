#!/bin/bash

DATADIR="/var/lib/mysql"
ROOT_PWD=$(cat /run/secrets/db_root_password)
MYSQL_PASSWORD=$(cat /run/secrets/db_password)
WP_SECOND_PASS=$(cat /run/secrets/wp_second_password)
ADMINER_PASS=$(cat /run/secrets/adminer_password)

if [ ! -d "$DATADIR/mysql" ]; then
    mysql_install_db --user=mysql --datadir="$DATADIR"
fi

cat << EOF > /tmp/init.sql
-- Create root user if not exists and grant global privileges
CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '$ROOT_PWD';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;

-- Create WordPress database
CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE;

-- Create main WordPress user
CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';

-- Create secondary WordPress user (read-only)
CREATE USER IF NOT EXISTS '$WP_SECOND_USER'@'%' IDENTIFIED BY '$WP_SECOND_PASS';
GRANT SELECT ON $MYSQL_DATABASE.* TO '$WP_SECOND_USER'@'%';

-- Create adminer user with root privileges
CREATE USER IF NOT EXISTS 'adminer'@'%' IDENTIFIED BY '$ADMINER_PASS';
GRANT ALL PRIVILEGES ON *.* TO 'adminer'@'%' WITH GRANT OPTION;

-- Apply privileges
FLUSH PRIVILEGES;

EOF

exec mysqld --user=mysql --bind-address=0.0.0.0 --init-file=/tmp/init.sql
