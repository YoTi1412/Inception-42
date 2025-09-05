#!/bin/bash

DATADIR="/var/lib/mysql"
SOCKET="/run/mysqld/mysqld.sock"
ROOT_PWD=$(cat /run/secrets/db_root_password)
MYSQL_PASSWORD=$(cat /run/secrets/db_password)
WP_SECOND_PASS=$(cat /run/secrets/wp_second_password)
INIT_SQL="/tmp/init.sql"

mkdir -p /run/mysqld "$DATADIR"
chown -R mysql:mysql /run/mysqld "$DATADIR"
chmod 775 /run/mysqld

if [ ! -d "$DATADIR/mysql" ]; then
    rm -rf "$DATADIR"/*
    mysql_install_db --user=mysql --datadir="$DATADIR"

    cat > "$INIT_SQL" << EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${ROOT_PWD}';
CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '${ROOT_PWD}';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
CREATE USER IF NOT EXISTS 'viewer'@'%' IDENTIFIED BY '${WP_SECOND_PASS}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
GRANT SELECT ON \`${MYSQL_DATABASE}\`.* TO 'viewer'@'%';
FLUSH PRIVILEGES;
EOF

    chown mysql:mysql "$INIT_SQL"
    chmod 600 "$INIT_SQL"

    # Start temporary server on socket
    mysqld --user=mysql --datadir="$DATADIR" --skip-networking --socket="$SOCKET" --init-file="$INIT_SQL" &
    PID=$!

    # Wait until server is ready
    for i in {1..30}; do
        mysqladmin ping --socket="$SOCKET" --silent && break
        sleep 1
    done

    # Stop temporary server
    mysqladmin --socket="$SOCKET" -uroot -p"$ROOT_PWD" shutdown
    wait $PID
fi

exec mysqld --user=mysql --bind-address=0.0.0.0
