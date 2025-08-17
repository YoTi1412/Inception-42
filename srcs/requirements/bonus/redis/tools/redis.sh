#!/bin/bash
set -e

# Log environment for debugging
echo "🔍 Environment variables:"
env

# Verify Redis binary
if ! command -v redis-server >/dev/null 2>&1; then
    echo "❌ redis-server not found"
    exit 1
fi

# Create data directory with correct permissions
echo "🔧 Setting up Redis data directory..."
mkdir -p /var/lib/redis
chown redis:redis /var/lib/redis
chmod 755 /var/lib/redis

# Backup original config
echo "🔧 Backing up Redis configuration..."
cp /etc/redis/redis.conf /etc/redis/redis.conf.bak.$(date +%s)

# Apply minimal configuration
echo "🔧 Applying Redis configuration..."
sed -i 's|^bind 127.0.0.1.*|bind 0.0.0.0|g' /etc/redis/redis.conf
sed -i '/^requirepass /d' /etc/redis/redis.conf
sed -i 's|^dir ./|dir /var/lib/redis/|g' /etc/redis/redis.conf
sed -i 's|^# maxmemory <bytes>|maxmemory 128mb|g' /etc/redis/redis.conf
sed -i 's|^# maxmemory-policy noeviction|maxmemory-policy allkeys-lru|g' /etc/redis/redis.conf
sed -i 's|^daemonize yes|daemonize no|g' /etc/redis/redis.conf
sed -i 's|^timeout 0|timeout 0|g' /etc/redis/redis.conf

# Add password if set
if [ -n "$REDIS_PASSWORD" ]; then
    echo "requirepass $REDIS_PASSWORD" >> /etc/redis/redis.conf
    echo "✅ Redis password set"
else
    echo "⚠️ REDIS_PASSWORD not set, running without authentication"
fi

# Start Redis server
echo "🚀 Starting Redis server..."
exec redis-server /etc/redis/redis.conf --loglevel verbose