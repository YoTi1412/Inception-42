FROM debian:bookworm-backports

# Install dependencies and Docker CLI
RUN apt-get update && \
    apt-get install -y \
    curl \
    ca-certificates \
    gnupg \
    lsb-release \
    docker.io \
    iptables \
    fuse \
    uidmap \
    bash \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Docker Compose plugin
RUN mkdir -p /root/.docker/cli-plugins && \
    curl -SL https://github.com/docker/compose/releases/download/v2.24.5/docker-compose-linux-x86_64 \
    -o /root/.docker/cli-plugins/docker-compose && \
    chmod +x /root/.docker/cli-plugins/docker-compose

# Set working directory
WORKDIR /app

# Copy entrypoint script
COPY tools/portainer-entrypoint.sh /usr/local/bin/portainer-entrypoint.sh
RUN chmod +x /usr/local/bin/portainer-entrypoint.sh

# Expose Portainer's default port
EXPOSE 9000

# Use custom entrypoint (if you're downloading and running Portainer from there)
ENTRYPOINT ["portainer-entrypoint.sh"]
