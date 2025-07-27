#!/bin/sh

if [ ! -f "/etc/vsftpd/vsftpd.conf.bak" ]; then

    echo "[+] Initial FTP setup..."

    mkdir -p /var/www/html
    mkdir -p /etc/vsftpd

    # Backup original conf file only if it exists
    if [ -f "/etc/vsftpd/vsftpd.conf" ]; then
        cp /etc/vsftpd/vsftpd.conf /etc/vsftpd/vsftpd.conf.bak
    fi

    # Move our custom config
    mv /tmp/vsftpd.conf /etc/vsftpd/vsftpd.conf

    # Create user if not already exists
    if ! id "$FTP_USER" >/dev/null 2>&1; then
        adduser "$FTP_USER" --disabled-password
    fi

    echo "$FTP_USER:$FTP_PASSWORD" | /usr/sbin/chpasswd &> /dev/null
    chown -R "$FTP_USER:$FTP_USER" /var/www/html

    echo "$FTP_USER" >> /etc/vsftpd.userlist
fi

mkdir -p /var/run/vsftpd/empty
chmod 755 /var/run/vsftpd/empty

echo "[+] FTP started on :21"
/usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf