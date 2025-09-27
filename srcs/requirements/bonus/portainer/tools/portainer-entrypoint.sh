#!/bin/bash

PORTAINER_URL="https://github.com/portainer/portainer/releases/download/${PORTAINER_VERSION}/portainer-${PORTAINER_VERSION}-linux-amd64.tar.gz"

mkdir -p /app/portainer
curl -L "$PORTAINER_URL" -o /app/portainer/portainer.tar.gz
tar -xzf /app/portainer/portainer.tar.gz -C /app/portainer --strip-components=1
rm /app/portainer/portainer.tar.gz
chmod +x /app/portainer/portainer

exec /app/portainer/portainer \
     --data /data \
     --admin-password-file /run/secrets/portainer_password
