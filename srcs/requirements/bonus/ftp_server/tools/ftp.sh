#!/bin/sh

FTP_PASSWORD=$(cat /run/secrets/ftp_password)

# One-time setup check
if [ ! -f /etc/vsftpd/vsftpd.conf.bak ]; then
    echo "Setting up FTP server..."

    mkdir -p /etc/vsftpd /var/www/html

    # Create www-data user/group (matching WordPress container)
    if ! getent group www-data >/dev/null 2>&1; then
        groupadd -g 33 www-data
    fi
    if ! getent passwd www-data >/dev/null 2>&1; then
        useradd -r -g www-data -u 33 -d /var/www -s /bin/false www-data
    fi

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
allow_writeable_chroot=YES
local_root=/var/www/html
listen=YES
listen_port=21
seccomp_sandbox=NO
pasv_enable=YES
pasv_min_port=21100
pasv_max_port=21110
userlist_enable=YES
userlist_file=/etc/vsftpd.userlist
userlist_deny=NO
local_umask=022
file_open_mode=0644
ftpd_banner=Welcome to FTP server of inception!
EOF

    cp /etc/vsftpd/vsftpd.conf /etc/vsftpd/vsftpd.conf.bak
fi

chown -R www-data:www-data /var/www/html
find /var/www/html -type d -exec chmod 755 {} \; 2>/dev/null || true
find /var/www/html -type f -exec chmod 644 {} \; 2>/dev/null || true

mkdir -p /var/run/vsftpd/empty
chmod 755 /var/run/vsftpd/empty

echo "Starting vsftpd..."
exec /usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf
