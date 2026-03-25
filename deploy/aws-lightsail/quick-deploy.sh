#!/bin/bash
# Quick deployment script for SmartEduConnect on Amazon Linux 2023
# Run as: bash deploy/aws-lightsail/quick-deploy.sh

set -e

echo "=========================================="
echo "SmartEduConnect Quick Deployment"
echo "Amazon Linux 2023 - Lightsail"
echo "=========================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
   echo -e "${RED}Please do not run as root. Run as ec2-user.${NC}"
   exit 1
fi

# Step 1: Install PHP
echo -e "${GREEN}Step 1: Installing PHP 8.2 and extensions...${NC}"
sudo dnf install -y php php-cli php-fpm php-mysqlnd php-pdo php-mbstring php-xml php-zip php-bcmath php-intl php-gd php-opcache

# Step 2: Install Composer
echo -e "${GREEN}Step 2: Installing Composer...${NC}"
if ! command -v composer &> /dev/null; then
    curl -sS https://getcomposer.org/installer | php
    sudo mv composer.phar /usr/local/bin/composer
    sudo chmod +x /usr/local/bin/composer
fi

# Step 3: Install MySQL/MariaDB
echo -e "${GREEN}Step 3: Installing MariaDB...${NC}"
sudo dnf install -y mariadb105-server
sudo systemctl enable mariadb
sudo systemctl start mariadb

echo -e "${YELLOW}Please run 'sudo mysql_secure_installation' after this script completes.${NC}"

# Step 4: Create database
echo -e "${GREEN}Step 4: Creating database...${NC}"
read -p "Enter database password for smarteduconnect user: " DB_PASSWORD

sudo mysql -e "CREATE DATABASE IF NOT EXISTS smarteduconnect CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
sudo mysql -e "CREATE USER IF NOT EXISTS 'smarteduconnect'@'localhost' IDENTIFIED BY '${DB_PASSWORD}';"
sudo mysql -e "GRANT ALL PRIVILEGES ON smarteduconnect.* TO 'smarteduconnect'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

echo -e "${GREEN}Database created successfully!${NC}"

# Step 5: Setup application directories
echo -e "${GREEN}Step 5: Setting up application directories...${NC}"
sudo mkdir -p /var/www/smarteduconnect-frontend
sudo chown -R ec2-user:ec2-user /var/www/smarteduconnect-frontend

# Assuming we're already in the cloned repo
REPO_DIR=$(pwd)
echo "Repository directory: $REPO_DIR"

# Step 6: Configure backend
echo -e "${GREEN}Step 6: Configuring backend...${NC}"
cd $REPO_DIR/backend

if [ ! -f .env ]; then
    cp .env.example .env
    
    # Update .env with database credentials
    sed -i "s/DB_DATABASE=.*/DB_DATABASE=smarteduconnect/" .env
    sed -i "s/DB_USERNAME=.*/DB_USERNAME=smarteduconnect/" .env
    sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=${DB_PASSWORD}/" .env
    sed -i "s|APP_URL=.*|APP_URL=https://smarteduconnect.com:8080|" .env
    sed -i "s|FRONTEND_URL=.*|FRONTEND_URL=https://smarteduconnect.com|" .env
    
    echo -e "${GREEN}.env file created and configured!${NC}"
else
    echo -e "${YELLOW}.env file already exists. Skipping...${NC}"
fi

# Step 7: Install backend dependencies
echo -e "${GREEN}Step 7: Installing backend dependencies...${NC}"
composer install --no-dev --optimize-autoloader

# Step 8: Generate key and run migrations
echo -e "${GREEN}Step 8: Running Laravel setup...${NC}"
php artisan key:generate --force
php artisan migrate --force
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Set permissions
sudo chown -R nginx:nginx storage bootstrap/cache
sudo chmod -R 775 storage bootstrap/cache

# Step 9: Build frontend
echo -e "${GREEN}Step 9: Building frontend...${NC}"
cd $REPO_DIR

# Create frontend .env
cat > .env << 'EOF'
VITE_API_BASE_URL=https://smarteduconnect.com:8080
EOF

npm install
npm run build

# Copy to frontend directory
cp -r dist/* /var/www/smarteduconnect-frontend/

# Step 10: Configure Nginx
echo -e "${GREEN}Step 10: Configuring Nginx...${NC}"

# Frontend config
sudo tee /etc/nginx/conf.d/smarteduconnect-frontend.conf > /dev/null <<'EOF'
server {
    listen 80;
    server_name smarteduconnect.com www.smarteduconnect.com;

    root /var/www/smarteduconnect-frontend;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location ~* \.(js|css|png|jpg|jpeg|svg|webp|ico|woff|woff2)$ {
        expires 30d;
        add_header Cache-Control "public, immutable";
        try_files $uri =404;
    }
}
EOF

# Backend config
sudo tee /etc/nginx/conf.d/smarteduconnect-backend.conf > /dev/null <<EOF
server {
    listen 8080;
    server_name smarteduconnect.com www.smarteduconnect.com;

    root $REPO_DIR/backend/public;
    index index.php index.html;

    client_max_body_size 20m;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php-fpm/www.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
EOF

# Test nginx config
sudo nginx -t

if [ $? -eq 0 ]; then
    echo -e "${GREEN}Nginx configuration is valid!${NC}"
    sudo systemctl reload nginx
else
    echo -e "${RED}Nginx configuration has errors. Please check manually.${NC}"
    exit 1
fi

# Step 11: Setup queue worker
echo -e "${GREEN}Step 11: Setting up queue worker...${NC}"

sudo tee /etc/systemd/system/smarteduconnect-queue.service > /dev/null <<EOF
[Unit]
Description=SmartEduConnect Queue Worker
After=network.target

[Service]
Type=simple
User=nginx
Group=nginx
Restart=always
RestartSec=5
ExecStart=/usr/bin/php $REPO_DIR/backend/artisan queue:work --sleep=3 --tries=3 --max-time=3600

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable smarteduconnect-queue.service
sudo systemctl start smarteduconnect-queue.service

echo ""
echo -e "${GREEN}=========================================="
echo "Deployment Complete!"
echo "==========================================${NC}"
echo ""
echo "Next steps:"
echo "1. Point smarteduconnect.com DNS to this server's IP"
echo "2. Open port 8080 in Lightsail firewall"
echo "3. Run: sudo certbot --nginx -d smarteduconnect.com -d www.smarteduconnect.com"
echo "4. Update backend nginx config for SSL on port 8080"
echo ""
echo "Check status:"
echo "  sudo systemctl status nginx"
echo "  sudo systemctl status php-fpm"
echo "  sudo systemctl status smarteduconnect-queue.service"
echo ""
echo "View logs:"
echo "  sudo tail -f /var/log/nginx/error.log"
echo "  tail -f $REPO_DIR/backend/storage/logs/laravel.log"
echo ""
