#!/bin/sh

FTP_PASSWORD=$(cat /run/secrets/ftp_password)

if [ ! -f /etc/vsftpd/vsftpd.conf.bak ]; then
  mkdir -p /etc/vsftpd /var/www/html
  mv /tmp/vsftpd.conf /etc/vsftpd/vsftpd.conf
  [ -f /etc/vsftpd/vsftpd.conf ] && cp /etc/vsftpd/vsftpd.conf /etc/vsftpd/vsftpd.conf.bak

  if ! id "$FTP_USER" >/dev/null 2>&1; then
    adduser --disabled-password --gecos "" "$FTP_USER"
  fi
  echo "$FTP_USER:$FTP_PASSWORD" | chpasswd >/dev/null 2>&1
  echo "$FTP_USER" >> /etc/vsftpd.userlist
fi

mkdir -p /var/run/vsftpd/empty
chmod 755 /var/run/vsftpd/empty
/usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf
