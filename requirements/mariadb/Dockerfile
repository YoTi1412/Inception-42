FROM debian:bookworm-backports

ENV DEBIAN_FRONTEND=noninteractive

# Install MariaDB Server
RUN apt-get update && \
    apt-get install -y mariadb-server mariadb-client vim && \
    rm -rf /var/lib/apt/lists/*

# Prepare MySQL runtime directory
RUN mkdir -p /var/run/mysqld && \
    chown -R mysql:mysql /var/run/mysqld && \
    chmod 775 /var/run/mysqld

# Create MySQL data directory
RUN mkdir -p /var/lib/mysql && \
    chown -R mysql:mysql /var/lib/mysql

COPY ./tools/script.sh /usr/local/bin/script.sh
RUN chmod +x /usr/local/bin/script.sh

EXPOSE 3306
ENTRYPOINT ["/usr/local/bin/script.sh"]