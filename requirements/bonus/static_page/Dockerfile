FROM debian:bookworm-backports

# Install Node.js, npm, Nginx, and build tools
RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    nginx \
    && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && apt-get install -y build-essential \
    && apt-get clean

# Create necessary directories
RUN mkdir -p /var/www/html /app

# Set working directory for the build
WORKDIR /app

# Copy package.json and install dependencies
COPY package.json package-lock.json ./
RUN npm install

# Copy the rest of the static page project
COPY . .

# Run the build process
RUN npm run build

# Copy built files to Nginx directory
RUN mv /app/public /var/www/html/public && \
    chown -R www-data:www-data /var/www/html/public && \
    chmod -R 755 /var/www/html/public
	
# Copy a basic Nginx configuration
COPY ./conf/nginx.conf /etc/nginx/sites-available/default

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]