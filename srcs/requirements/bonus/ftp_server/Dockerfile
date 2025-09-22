FROM debian:bookworm-backports

RUN apt-get update && \
    apt-get install -y vsftpd libpam-modules && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

COPY tools/ftp.sh /tmp/ftp.sh
RUN chmod +x /tmp/ftp.sh

ENTRYPOINT ["sh", "/tmp/ftp.sh"]
