#!/bin/bash

PORTAINER_VERSION=2.27.9
PORTAINER_URL="https://github.com/portainer/portainer/releases/download/${PORTAINER_VERSION}/portainer-${PORTAINER_VERSION}-linux-amd64.tar.gz"

echo "📦 Downloading Portainer CE ${PORTAINER_VERSION}..."
mkdir -p /app

curl -L "$PORTAINER_URL" -o /app/portainer.tar.gz

echo "📂 Extracting..."
tar -xzf /app/portainer.tar.gz -C /app

rm /app/portainer.tar.gz

echo "✅ Starting Portainer..."
exec /app/portainer/portainer
