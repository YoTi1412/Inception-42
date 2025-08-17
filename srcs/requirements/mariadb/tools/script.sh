#!/bin/bash
set -e

DATADIR="/var/lib/mysql"
SOCKET="/run/mysqld/mysqld.sock"
ROOT_PWD="$MYSQL_ROOT_PASSWORD"
INIT_SQL="/tmp/init.sql"

echo "🔧 MariaDB one-shot bootstrap"

# 1. Clean up old socket and PID files
rm -f /run/mysqld/mysqld.sock /run/mysqld/mysqld.pid /tmp/mysql-init.pid "$INIT_SQL"

# 2. Ensure /tmp and directories are writable
chmod 1777 /tmp
mkdir -p /run/mysqld "$DATADIR"
chown -R mysql:mysql /run/mysqld "$DATADIR"
chmod 775 /run/mysqld

# 3. Check if database is already initialized and WordPress DB exists
if [[ -d "$DATADIR/mysql" && -f "$DATADIR/ibdata1" ]]; then
    echo "✅ Database system already initialized, checking WordPress DB..."
    
    # Start temporary MariaDB (socket only)
    mysqld --user=mysql --datadir="$DATADIR" --skip-networking --socket="$SOCKET" &
    PID=$!
    
    # Wait until ready
    for i in {1..20}; do
        if mysqladmin ping --socket="$SOCKET" --silent; then
            break
        fi
        sleep 1
    done
    
    # Check if WordPress DB has at least one table
    if mysql --socket="$SOCKET" -uroot -p"$ROOT_PWD" -e "USE ${MYSQL_DATABASE}; SHOW TABLES;" | grep -q .; then
        echo "✅ WordPress DB already exists with tables, skipping init."
        mysqladmin -uroot -p"$ROOT_PWD" --socket="$SOCKET" shutdown
        wait $PID
        exec mysqld --user=mysql --bind-address=0.0.0.0
    else
        echo "⚠️ WordPress DB missing or empty, proceeding with fresh initialization..."
        mysqladmin -uroot -p"$ROOT_PWD" --socket="$SOCKET" shutdown
        wait $PID
    fi
fi

# 4. Remove residual data to force clean initialization
echo "🧹 Cleaning residual data for fresh initialization..."
rm -rf "$DATADIR"/*
mkdir -p "$DATADIR"
chown -R mysql:mysql "$DATADIR"

# 5. Perform fresh install
echo "📦 Initializing new MariaDB database..."
mysql_install_db --user=mysql --datadir="$DATADIR" --skip-test-db

# 6. Create init SQL file
cat > "$INIT_SQL" << EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${ROOT_PWD}';
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
CREATE USER IF NOT EXISTS 'viewer'@'%' IDENTIFIED BY '${WP_SECOND_PASS}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
GRANT SELECT ON \`${MYSQL_DATABASE}\`.* TO 'viewer'@'%';
FLUSH PRIVILEGES;
EOF
chown mysql:mysql "$INIT_SQL"
chmod 600 "$INIT_SQL"

# 7. Start temporary server on a Unix socket
echo "🚀 Starting temporary MariaDB server for initialization..."
mysqld --user=mysql \
       --datadir="$DATADIR" \
       --skip-networking \
       --socket="$SOCKET" \
       --pid-file=/tmp/mysql-init.pid \
       --skip-log-bin \
       --init-file="$INIT_SQL" &
PID=$!

# 8. Wait for the temporary server to be ready (up to 30 seconds)
for i in {1..30}; do
    if mysqladmin ping --socket="$SOCKET" --silent; then
        echo "✅ Temporary MariaDB server is up"
        break
    fi
    echo "⏳ Waiting for temporary MariaDB server ($i/30)..."
    sleep 1
done

if ! mysqladmin ping --socket="$SOCKET" --silent; then
    echo "❌ Failed to start temporary MariaDB server"
    exit 1
fi

# 9. Verify user creation
if mysql --socket="$SOCKET" -uroot -p"$ROOT_PWD" -e "SELECT User FROM mysql.user WHERE User IN ('${MYSQL_USER}', 'viewer');" | grep -q "${MYSQL_USER}"; then
    echo "✅ MySQL user '${MYSQL_USER}' created successfully"
else
    echo "❌ Failed to create MySQL user '${MYSQL_USER}'"
    exit 1
fi
if mysql --socket="$SOCKET" -uroot -p"$ROOT_PWD" -e "SELECT User FROM mysql.user WHERE User IN ('${MYSQL_USER}', 'viewer');" | grep -q "viewer"; then
    echo "✅ MySQL user 'viewer' created successfully"
else
    echo "❌ Failed to create MySQL user 'viewer'"
    exit 1
fi

# 10. Import WordPress dump if present
if [[ -f /docker-entrypoint-initdb.d/wordpress.sql ]]; then
    echo "📦 Importing initial WordPress data..."
    mysql --socket="$SOCKET" -uroot -p"$ROOT_PWD" "$MYSQL_DATABASE" < /docker-entrypoint-initdb.d/wordpress.sql
fi

# 11. Stop temporary server
echo "🛑 Shutting down temporary MariaDB server..."
mysqladmin -uroot -p"$ROOT_PWD" --socket="$SOCKET" shutdown
wait $PID

# 12. Start the real server
echo "✅ Bootstrap complete – starting MariaDB server..."
exec mysqld --user=mysql --bind-address=0.0.0.0