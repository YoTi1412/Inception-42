sudo chown -R www-data:www-data /home/yoti/data/wordpress/wp-content/
sudo find /home/yoti/data/wordpress/wp-content/ -type d -exec chmod 755 {} \;
sudo find /home/yoti/data/wordpress/wp-content/ -type f -exec chmod 644 {} \;
