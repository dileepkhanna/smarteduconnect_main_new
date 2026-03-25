# SmartEduConnect Deployment on Lightsail (Amazon Linux 2023)
## For existing instance with Django+React and Next.js

### Current Setup Analysis
```
Port 80/443: Nginx (existing projects)
Port 3000: Next.js
Port 8000: Nginx → Django
Port 8001: Django backend
Port 5432: PostgreSQL
Port 6379/6380: Redis/Valkey
```

### SmartEduConnect Configuration
- **Frontend**: https://smarteduconnect.com (port 80/443)
- **Backend API**: https://smarteduconnect.com:8080 (port 8080)

---

## Step 1: Check Nginx Configuration Location

```bash
# Find nginx config files
sudo nginx -t

# Check main config
cat /etc/nginx/nginx.conf | grep include

# Common locations:
ls -la /etc/nginx/conf.d/
ls -la /etc/nginx/default.d/
```

---

## Step 2: Install PHP 8.2

```bash
# Check current PHP version
php -v

# Install PHP 8.2 and extensions for Amazon Linux 2023
sudo dnf install -y \
  php8.2 \
  php8.2-cli \
  php8.2-common \
  php8.2-fpm \
  php8.2-mysqlnd \
  php8.2-pdo \
  php8.2-mbstring \
  php8.2-xml \
  php8.2-zip \
  php8.2-bcmath \
  php8.2-intl \
  php8.2-gd \
  php8.2-opcache

# If php8.2 is not available, try:
# sudo dnf install -y php php-cli php-fpm php-mysqlnd php-pdo php-mbstring php-xml php-zip php-bcmath php-intl php-gd php-opcache

# Start PHP-FPM
sudo systemctl enable php-fpm
sudo systemctl start php-fpm
sudo systemctl status php-fpm
```

---

## Step 3: Install Composer

```bash
# Check if composer exists
composer --version

# If not installed:
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
chmod +x /usr/local/bin/composer
```

---

## Step 4: Install MySQL (if not using PostgreSQL for this project)

```bash
# Install MySQL for Amazon Linux 2023
sudo dnf install -y mariadb105-server
sudo systemctl enable mariadb
sudo systemctl start mariadb

# Secure installation
sudo mysql_secure_installation

# Create database
sudo mysql
```

In MySQL:
```sql
CREATE DATABASE smarteduconnect CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'smarteduconnect'@'localhost' IDENTIFIED BY 'YOUR_SECURE_PASSWORD';
GRANT ALL PRIVILEGES ON smarteduconnect.* TO 'smarteduconnect'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

**Alternative: Use PostgreSQL (already installed)**
```bash
sudo -u postgres psql
```

In PostgreSQL:
```sql
CREATE DATABASE smarteduconnect;
CREATE USER smarteduconnect WITH PASSWORD 'YOUR_SECURE_PASSWORD';
GRANT ALL PRIVILEGES ON DATABASE smarteduconnect TO smarteduconnect;
\q
```

---

## Step 5: Clone and Setup Application

```bash
# Navigate to web directory
cd /var/www

# Clone repository
sudo git clone https://github.com/dileepkhanna/smarteduconnect_main_new.git smarteduconnect
sudo chown -R ec2-user:ec2-user smarteduconnect

# Create frontend directory
sudo mkdir -p /var/www/smarteduconnect-frontend
sudo chown -R ec2-user:ec2-user /var/www/smarteduconnect-frontend
```

---

## Step 6: Configure Backend

```bash
cd /var/www/smarteduconnect/backend
cp .env.example .env
nano .env
```

**For MySQL:**
```env
APP_NAME="SmartEduConnect"
APP_ENV=production
APP_DEBUG=false
APP_URL=https://smarteduconnect.com:8080
FRONTEND_URL=https://smarteduconnect.com

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=smarteduconnect
DB_USERNAME=smarteduconnect
DB_PASSWORD=YOUR_SECURE_PASSWORD

FILESYSTEM_DISK=s3
AWS_ACCESS_KEY_ID=your_aws_key
AWS_SECRET_ACCESS_KEY=your_aws_secret
AWS_DEFAULT_REGION=ap-south-2
AWS_BUCKET=schoolwebapp1

QUEUE_CONNECTION=database
SESSION_DRIVER=database
SESSION_SECURE_COOKIE=true
ALLOWED_ORIGINS=https://smarteduconnect.com
```

**For PostgreSQL:**
```env
DB_CONNECTION=pgsql
DB_HOST=127.0.0.1
DB_PORT=5432
DB_DATABASE=smarteduconnect
DB_USERNAME=smarteduconnect
DB_PASSWORD=YOUR_SECURE_PASSWORD
```

---

## Step 7: Build and Deploy

```bash
cd /var/www/smarteduconnect

# Create frontend .env
cat > .env << 'EOF'
VITE_API_BASE_URL=https://smarteduconnect.com:8080
EOF

# Install and build frontend
npm install
npm run build

# Copy frontend build
cp -r dist/* /var/www/smarteduconnect-frontend/

# Install backend dependencies
cd backend
composer install --no-dev --optimize-autoloader

# Run Laravel setup
php artisan key:generate --force
php artisan migrate --force
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Set permissions
sudo chown -R nginx:nginx storage bootstrap/cache
sudo chmod -R 775 storage bootstrap/cache
```

---

## Step 8: Configure Nginx

First, find where your nginx configs are:
```bash
cat /etc/nginx/nginx.conf | grep "include.*conf"
```

Likely locations:
- `/etc/nginx/conf.d/*.conf`
- `/etc/nginx/default.d/*.conf`

Create frontend config:
```bash
sudo nano /etc/nginx/conf.d/smarteduconnect-frontend.conf
```

Add:
```nginx
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
```

Create backend config:
```bash
sudo nano /etc/nginx/conf.d/smarteduconnect-backend.conf
```

Add:
```nginx
server {
    listen 8080;
    server_name smarteduconnect.com www.smarteduconnect.com;

    root /var/www/smarteduconnect/backend/public;
    index index.php index.html;

    client_max_body_size 20m;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php-fpm/www.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
```

Test and reload:
```bash
sudo nginx -t
sudo systemctl reload nginx
```

---

## Step 9: Open Port 8080 in Security Group

1. Go to EC2 Console
2. Select your instance
3. Click "Security" tab
4. Click on the security group
5. Edit inbound rules
6. Add rule:
   - Type: Custom TCP
   - Port: 8080
   - Source: 0.0.0.0/0 (or your specific IPs)

---

## Step 10: Setup Queue Worker

```bash
sudo nano /etc/systemd/system/smarteduconnect-queue.service
```

Add:
```ini
[Unit]
Description=SmartEduConnect Queue Worker
After=network.target

[Service]
Type=simple
User=nginx
Group=nginx
Restart=always
RestartSec=5
ExecStart=/usr/bin/php /var/www/smarteduconnect/backend/artisan queue:work --sleep=3 --tries=3 --max-time=3600

[Install]
WantedBy=multi-user.target
```

Enable and start:
```bash
sudo systemctl daemon-reload
sudo systemctl enable smarteduconnect-queue.service
sudo systemctl start smarteduconnect-queue.service
sudo systemctl status smarteduconnect-queue.service
```

---

## Step 11: Configure DNS

Point `smarteduconnect.com` to your EC2 instance IP:

1. In your domain registrar (GoDaddy, Namecheap, etc.)
2. Add A record:
   - Host: `@` or `smarteduconnect`
   - Points to: `YOUR_EC2_PUBLIC_IP`
   - TTL: 3600

---

## Step 12: Setup SSL with Certbot

```bash
# Install Certbot for Amazon Linux 2023
sudo dnf install -y certbot python3-certbot-nginx

# Get certificate
sudo certbot --nginx -d smarteduconnect.com -d www.smarteduconnect.com

# Follow prompts
```

For port 8080 SSL, update backend config:
```bash
sudo nano /etc/nginx/conf.d/smarteduconnect-backend.conf
```

Update to:
```nginx
server {
    listen 8080 ssl;
    server_name smarteduconnect.com www.smarteduconnect.com;

    ssl_certificate /etc/letsencrypt/live/smarteduconnect.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/smarteduconnect.com/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    root /var/www/smarteduconnect/backend/public;
    index index.php index.html;

    client_max_body_size 20m;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php-fpm/www.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
```

Test and reload:
```bash
sudo nginx -t
sudo systemctl reload nginx
```

---

## Step 13: Verify Deployment

```bash
# Check all services
sudo systemctl status nginx
sudo systemctl status php-fpm
sudo systemctl status smarteduconnect-queue.service

# Check ports
sudo netstat -tulpn | grep LISTEN

# Check logs
sudo tail -f /var/log/nginx/error.log
tail -f /var/www/smarteduconnect/backend/storage/logs/laravel.log
```

Test in browser:
1. https://smarteduconnect.com (frontend)
2. https://smarteduconnect.com:8080 (backend API)

---

## Port Summary After Deployment

```
Port 80/443: Nginx (Django/React, Next.js, SmartEduConnect frontend)
Port 3000: Next.js
Port 8000: Nginx → Django
Port 8001: Django backend
Port 8080: SmartEduConnect backend API ← NEW
Port 5432: PostgreSQL
Port 6379/6380: Redis/Valkey
```

---

## Troubleshooting

### Check PHP-FPM socket location
```bash
sudo find /var/run -name "*php*"
# Update nginx config with correct socket path
```

### Check PHP-FPM status
```bash
sudo systemctl status php-fpm
sudo tail -f /var/log/php-fpm/error.log
```

### Check Laravel logs
```bash
tail -f /var/www/smarteduconnect/backend/storage/logs/laravel.log
```

### Check Nginx logs
```bash
sudo tail -f /var/log/nginx/error.log
sudo tail -f /var/log/nginx/access.log
```

### Clear Laravel cache
```bash
cd /var/www/smarteduconnect/backend
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear
php artisan config:cache
php artisan route:cache
```

### Restart all services
```bash
sudo systemctl restart nginx
sudo systemctl restart php-fpm
sudo systemctl restart smarteduconnect-queue.service
```

---

## Updating Application

```bash
cd /var/www/smarteduconnect
git pull origin main

# Rebuild frontend
npm install
npm run build
cp -r dist/* /var/www/smarteduconnect-frontend/

# Update backend
cd backend
composer install --no-dev --optimize-autoloader
php artisan migrate --force
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Restart services
sudo systemctl restart smarteduconnect-queue.service
```

---

## Quick Commands Reference

```bash
# Check all ports
sudo netstat -tulpn | grep LISTEN

# Restart SmartEduConnect services
sudo systemctl restart nginx php-fpm smarteduconnect-queue.service

# View logs
sudo tail -f /var/log/nginx/error.log
tail -f /var/www/smarteduconnect/backend/storage/logs/laravel.log

# Check queue worker
sudo systemctl status smarteduconnect-queue.service
sudo journalctl -u smarteduconnect-queue.service -f
```
