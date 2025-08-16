#!/bin/bash

DATADIR="/var/lib/mysql"
SOCKET="/run/mysqld/mysqld.sock"
ROOT_PWD="$MYSQL_ROOT_PASSWORD"
INIT_SQL="/tmp/init.sql"

echo "🔧 MariaDB one-shot bootstrap"

# 0. Clean up old socket and PID files
rm -f /run/mysqld/mysqld.sock /tmp/mysql-init.pid "$INIT_SQL"

# 1. Ensure /tmp is writable
chmod 1777 /tmp

# 2. directories
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld "$DATADIR"

# 3. Check if database is already initialized
if [[ -d "$DATADIR/mysql" ]]; then
    echo "✅ Database already initialized, skipping bootstrap..."
    exec mysqld --user=mysql --bind-address=0.0.0.0
fi

# 4. fresh install if needed
mysql_install_db --user=mysql --datadir="$DATADIR"

# 5. create init SQL file
cat > "$INIT_SQL" << EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${ROOT_PWD}';
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF
chown mysql:mysql "$INIT_SQL"
chmod 600 "$INIT_SQL"

# 6. start temporary server on a Unix socket
mysqld --user=mysql \
       --datadir="$DATADIR" \
       --skip-networking \
       --socket="$SOCKET" \
       --pid-file=/tmp/mysql-init.pid \
       --skip-log-bin \
       --init-file="$INIT_SQL" &
PID=$!

# 7. wait for it
until mysqladmin ping --socket="$SOCKET" --silent; do sleep 1; done

# 8. import WordPress dump if present
if [[ -f /docker-entrypoint-initdb.d/wordpress.sql ]]; then
    echo "📦 Importing initial data..."
    mysql --socket="$SOCKET" -uroot -p"$ROOT_PWD" "$MYSQL_DATABASE" \
        < /docker-entrypoint-initdb.d/wordpress.sql
fi

# 9. stop temporary server
mysqladmin -uroot -p"$ROOT_PWD" --socket="$SOCKET" shutdown
wait $PID

# 10. start the real server
echo "✅ Bootstrap complete – starting MariaDB server..."
exec mysqld --user=mysql --bind-address=0.0.0.0