#!/bin/bash

DATADIR="/var/lib/mysql"
ROOT_PWD=$(cat /run/secrets/db_root_password)
MYSQL_PASSWORD=$(cat /run/secrets/db_password)
WP_SECOND_PASS=$(cat /run/secrets/wp_second_password)

if [ ! -d "$DATADIR/mysql" ]; then
  mysql_install_db --user=mysql --datadir="$DATADIR"
fi

cat << EOF > /tmp/init.sql
ALTER USER 'root'@'localhost' IDENTIFIED BY '$ROOT_PWD';
CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\`;
CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
CREATE USER IF NOT EXISTS '$WP_SECOND_USER'@'%' IDENTIFIED BY '$WP_SECOND_PASS';
GRANT ALL PRIVILEGES ON \`$MYSQL_DATABASE\`.* TO '$MYSQL_USER'@'%';
GRANT SELECT ON \`$MYSQL_DATABASE\`.* TO '$WP_SECOND_USER'@'%';
FLUSH PRIVILEGES;
EOF

mysqld --user=mysql --bind-address=0.0.0.0 --init-file=/tmp/init.sql
