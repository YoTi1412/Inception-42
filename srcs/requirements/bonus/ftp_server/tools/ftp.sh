#!/bin/sh

FTP_PASSWORD=$(cat /run/secrets/ftp_password)

# One-time setup check
if [ ! -f /etc/vsftpd/vsftpd.conf.bak ]; then
    echo "Setting up FTP server..."

    mkdir -p /etc/vsftpd

    # Create FTP user
    if ! id "$FTP_USER" >/dev/null 2>&1; then
        adduser --disabled-password --gecos "" "$FTP_USER"
        usermod -a -G www-data "$FTP_USER"
        echo "$FTP_USER:$FTP_PASSWORD" | chpasswd
        echo "$FTP_USER" >> /etc/vsftpd.userlist
    fi

    cat > /etc/vsftpd/vsftpd.conf <<EOF
anonymous_enable=NO
local_enable=YES
write_enable=YES
chroot_local_user=YES
local_root=/var/www/html
listen=YES
listen_port=21
pasv_enable=YES
pasv_min_port=21100
pasv_max_port=21110
userlist_enable=YES
userlist_file=/etc/vsftpd.userlist
userlist_deny=NO
ftpd_banner=Welcome to FTP server of inception!
EOF

    cp /etc/vsftpd/vsftpd.conf /etc/vsftpd/vsftpd.conf.bak
fi

mkdir -p /var/run/vsftpd/empty
chmod 755 /var/run/vsftpd/empty

echo "Starting vsftpd..."
exec /usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf
