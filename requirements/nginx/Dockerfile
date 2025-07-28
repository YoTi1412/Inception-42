FROM debian:bookworm-backports

# Install all required packages
RUN apt-get update && apt-get install -y nginx openssl

# Create directories
RUN mkdir -p /etc/nginx/ssl /run/nginx /var/www/html

# Copy nginx config and the entrypoint script
COPY ./conf/nginx.conf /etc/nginx/conf.d/default.conf
COPY ./tools/entrypoint.sh /entrypoint.sh

# Make the entrypoint executable
RUN chmod +x /entrypoint.sh

# Only allow HTTPS
EXPOSE 443

# Run entrypoint script
CMD ["/entrypoint.sh"]