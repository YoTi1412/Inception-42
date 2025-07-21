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

# Copy init SQL and setup script
COPY ./tools/script.sh /docker-entrypoint-initdb.d/script.sh
COPY ./conf/wordpress.sql /docker-entrypoint-initdb.d/wordpress.sql

RUN chmod +x /docker-entrypoint-initdb.d/script.sh

EXPOSE 3306

# Run MariaDB directly
CMD ["mysqld", "--user=mysql", "--bind-address=0.0.0.0"]
