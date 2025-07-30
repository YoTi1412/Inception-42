#!/bin/sh

cp /etc/redis/redis.conf /etc/redis/redis.conf.bak.$(date +%s)

# ensure bind is commented
sed -i "s|^bind 127.0.0.1|#bind 127.0.0.1|g" /etc/redis/redis.conf

# remove any previous requirepass
sed -i '/^requirepass /d' /etc/redis/redis.conf
[ -n "$REDIS_PASSWORD" ] && echo "requirepass $REDIS_PASSWORD" >> /etc/redis/redis.conf

sed -i "s|^# maxmemory <bytes>|maxmemory 2mb|g" /etc/redis/redis.conf
sed -i "s|^# maxmemory-policy noeviction|maxmemory-policy allkeys-lru|g" /etc/redis/redis.conf

redis-server --protected-mode no --requirepass "$REDIS_PASSWORD"