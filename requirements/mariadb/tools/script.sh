#!/bin/bash
set -euo pipefail

DATADIR="/var/lib/mysql"
SOCKET="/run/mysqld/mysqld.sock"
ROOT_PWD="${MYSQL_ROOT_PASSWORD:-yotipassroot}"
INIT_SQL="/tmp/init.sql"

echo "🔧 MariaDB one-shot bootstrap"

# 0. directories
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld "$DATADIR"

# 1. fresh install if needed
[[ -d "$DATADIR/mysql" ]] || mysql_install_db --user=mysql --datadir="$DATADIR"

# 2. create init SQL file
cat > "$INIT_SQL" <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${ROOT_PWD}';
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF
chown mysql:mysql "$INIT_SQL"

# 3. start temporary server on a Unix socket
mysqld --user=mysql \
       --datadir="$DATADIR" \
       --skip-networking \
       --socket="$SOCKET" \
       --pid-file=/tmp/mysql-init.pid \
       --skip-log-bin \
       --init-file="$INIT_SQL" &
PID=$!

# 4. wait for it
until mysqladmin ping --socket="$SOCKET" --silent; do sleep 1; done

# 5. import WordPress dump if present
if [[ -f /docker-entrypoint-initdb.d/wordpress.sql ]]; then
    echo "📦 Importing initial data..."
    mysql --socket="$SOCKET" -uroot -p"$ROOT_PWD" "$MYSQL_DATABASE" \
        < /docker-entrypoint-initdb.d/wordpress.sql
fi

# 6. stop temporary server
mysqladmin -uroot -p"$ROOT_PWD" --socket="$SOCKET" shutdown
wait $PID

# 7. start the real server
echo "✅ Bootstrap complete – starting MariaDB server..."
exec mysqld --user=mysql --bind-address=0.0.0.0