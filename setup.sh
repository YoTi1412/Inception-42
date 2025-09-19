#!/bin/bash

DATA_DIR="/home/yoti/data"
MYSQL_DIR="$DATA_DIR/mysql"
WORDPRESS_DIR="$DATA_DIR/wordpress"
PORTAINER_DIR="$DATA_DIR/portainer"

echo "📁 Creating data directories if they don't exist..."
mkdir -p "$MYSQL_DIR" "$WORDPRESS_DIR" "$PORTAINER_DIR"


echo "🔐 Setting permissions for container users..."
chown -R 999:999 "$MYSQL_DIR"
chown -R 33:33 "$WORDPRESS_DIR"
chown -R 0:0 "$PORTAINER_DIR"
chmod -R u+rwX "$MYSQL_DIR" "$WORDPRESS_DIR" "$PORTAINER_DIR"

if [ "$1" = "--nuke" ]; then
    echo "💥 Clearing all data in $DATA_DIR..."
    rm -rf "$MYSQL_DIR"/* "$WORDPRESS_DIR"/* "$PORTAINER_DIR"/*
fi

echo "✅ Setup complete. You can now run 'make'."
