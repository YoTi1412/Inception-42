FROM debian:bookworm-backports

RUN apt-get update && \
    apt-get install -y redis-server && \
    rm -rf /var/lib/apt/lists/*

COPY ./conf/redis.conf /etc/redis/redis.conf

COPY ./tools/redis.sh /redis.sh
RUN chmod +x /redis.sh

EXPOSE 6379

ENTRYPOINT ["/redis.sh"]