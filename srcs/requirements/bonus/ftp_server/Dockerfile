FROM debian:bookworm-backports

RUN apt update \
	&& apt install vsftpd -y

COPY conf/vsftpd.conf /tmp/vsftpd.conf

COPY tools/ftp.sh /tmp/ftp.sh
ENTRYPOINT ["sh", "/tmp/ftp.sh"]