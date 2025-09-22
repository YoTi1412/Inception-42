FROM debian:bookworm-backports

RUN apt-get update && \
    apt-get install -y mariadb-server mariadb-client && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/run/mysqld /var/lib/mysql && \
    chown -R mysql:mysql /var/run/mysqld /var/lib/mysql

RUN sed -i "s/127.0.0.1/0.0.0.0/" /etc/mysql/mariadb.conf.d/50-server.cnf

COPY ./tools/script.sh /usr/local/bin/script.sh
RUN chmod +x /usr/local/bin/script.sh

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/script.sh"]
