#!/bin/sh

REDIS_PASSWORD=$(cat /run/secrets/redis_password)

sed -i "s/__REDIS_PASSWORD__/$REDIS_PASSWORD/g" /etc/redis/redis.conf

mkdir -p /var/lib/redis
chown redis:redis /var/lib/redis

echo "Redis is running"
exec redis-server /etc/redis/redis.conf