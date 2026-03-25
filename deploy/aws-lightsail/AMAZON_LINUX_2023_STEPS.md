# SmartEduConnect Deployment - Amazon Linux 2023
## Step-by-Step Guide for Your Lightsail Instance

### Your Current Setup
```
✓ Nginx running (ports 80, 443, 8000)
✓ Node.js (port 3000 - Next.js)
✓ Python/Django (port 8001)
✓ PostgreSQL (port 5432)
✓ Redis/Valkey (ports 6379, 6380)
```

### What We'll Add
```
→ SmartEduConnect Frontend (port 80/443 - new domain)
→ SmartEduConnect Backend (port 8080 - NEW)
→ PHP 8.2 + PHP-FPM
→ MariaDB (or use existing PostgreSQL)
```

---

## Quick Start (Automated)

```bash
# SSH into your Lightsail instance
ssh ec2-user@your-lightsail-ip

# Clone the repository
cd /var/www
sudo git clone https://github.com/dileepkhanna/smarteduconnect_main_new.git smarteduconnect
sudo chown -R ec2-user:ec2-user smarteduconnect
cd smarteduconnect

# Run the quick deploy script
bash deploy/aws-lightsail/quick-deploy.sh
```

The script will:
- Install PHP 8.2 and extensions
- Install Composer
- Install MariaDB
- Create database
- Configure Laravel
- Build frontend
- Setup Nginx
- Create systemd service for queue worker

---

## Manual Steps (If you prefer step-by-step)

### 1. Install PHP 8.2

```bash
sudo dnf install -y php php-cli php-fpm php-mysqlnd php-pdo php-mbstring php-xml php-zip php-bcmath php-intl php-gd php-opcache

# Start PHP-FPM
sudo systemctl enable php-fpm
sudo systemctl start php-fpm
sudo systemctl status php-fpm
```

### 2. Install Composer

```bash
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
sudo chmod +x /usr/local/bin/composer
composer --version
```

### 3. Install MariaDB (or use PostgreSQL)

**Option A: MariaDB (recommended for Laravel)**
```bash
sudo dnf install -y mariadb105-server
sudo systemctl enable mariadb
sudo systemctl start mariadb
sudo mysql_secure_installation
```

**Option B: Use existing PostgreSQL**
```bash
# Just create a new database in PostgreSQL
sudo -u postgres psql
```

### 4. Create Database

**For MariaDB:**
```bash
sudo mysql
```
```sql
CREATE DATABASE smarteduconnect CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'smarteduconnect'@'localhost' IDENTIFIED BY 'YOUR_SECURE_PASSWORD';
GRANT ALL PRIVILEGES ON smarteduconnect.* TO 'smarteduconnect'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

**For PostgreSQL:**
```bash
sudo -u postgres psql
```
```sql
CREATE DATABASE smarteduconnect;
CREATE USER smarteduconnect WITH PASSWORD 'YOUR_SECURE_PASSWORD';
GRANT ALL PRIVILEGES ON DATABASE smarteduconnect TO smarteduconnect;
\q
```

### 5. Clone Repository

```bash
cd /var/www
sudo git clone https://github.com/dileepkhanna/smarteduconnect_main_new.git smarteduconnect
sudo chown -R ec2-user:ec2-user smarteduconnect
cd smarteduconnect
```

### 6. Configure Backend

```bash
cd backend
cp .env.example .env
nano .env
```

Update these values:
```env
APP_URL=https://smarteduconnect.com:8080
FRONTEND_URL=https://smarteduconnect.com

# For MariaDB:
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=smarteduconnect
DB_USERNAME=smarteduconnect
DB_PASSWORD=YOUR_SECURE_PASSWORD

# For PostgreSQL:
# DB_CONNECTION=pgsql
# DB_HOST=127.0.0.1
# DB_PORT=5432
# DB_DATABASE=smarteduconnect
# DB_USERNAME=smarteduconnect
# DB_PASSWORD=YOUR_SECURE_PASSWORD

# S3 Storage (optional but recommended)
FILESYSTEM_DISK=s3
AWS_ACCESS_KEY_ID=your_key
AWS_SECRET_ACCESS_KEY=your_secret
AWS_DEFAULT_REGION=ap-south-2
AWS_BUCKET=schoolwebapp1
```

### 7. Install Dependencies and Setup Laravel

```bash
# Install backend dependencies
composer install --no-dev --optimize-autoloader

# Generate key and migrate
php artisan key:generate --force
php artisan migrate --force
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Set permissions
sudo chown -R nginx:nginx storage bootstrap/cache
sudo chmod -R 775 storage bootstrap/cache
```

### 8. Build Frontend

```bash
cd /var/www/smarteduconnect

# Create frontend .env
cat > .env << 'EOF'
VITE_API_BASE_URL=https://smarteduconnect.com:8080
EOF

# Build
npm install
npm run build

# Create frontend directory and copy build
sudo mkdir -p /var/www/smarteduconnect-frontend
sudo chown -R ec2-user:ec2-user /var/www/smarteduconnect-frontend
cp -r dist/* /var/www/smarteduconnect-frontend/
```

### 9. Configure Nginx

**Frontend config:**
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

**Backend config:**
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

**Test and reload:**
```bash
sudo nginx -t
sudo systemctl reload nginx
```

### 10. Setup Queue Worker

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

### 11. Open Port 8080 in Lightsail

1. Go to AWS Lightsail Console
2. Click on your instance
3. Go to "Networking" tab
4. Click "Add rule" under Firewall
5. Add:
   - Application: Custom
   - Protocol: TCP
   - Port: 8080
   - Source: Anywhere (0.0.0.0/0)

### 12. Configure DNS

In your domain registrar:
- Add A record: `smarteduconnect.com` → Your Lightsail IP
- Add A record: `www.smarteduconnect.com` → Your Lightsail IP

Wait 5-30 minutes for DNS propagation.

### 13. Setup SSL

```bash
# Install Certbot
sudo dnf install -y certbot python3-certbot-nginx

# Get certificate
sudo certbot --nginx -d smarteduconnect.com -d www.smarteduconnect.com
```

**Update backend for SSL on port 8080:**
```bash
sudo nano /etc/nginx/conf.d/smarteduconnect-backend.conf
```

Change first line to:
```nginx
listen 8080 ssl;
```

Add SSL lines after server_name:
```nginx
ssl_certificate /etc/letsencrypt/live/smarteduconnect.com/fullchain.pem;
ssl_certificate_key /etc/letsencrypt/live/smarteduconnect.com/privkey.pem;
include /etc/letsencrypt/options-ssl-nginx.conf;
ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;
```

Test and reload:
```bash
sudo nginx -t
sudo systemctl reload nginx
```

---

## Verification

```bash
# Check all services
sudo systemctl status nginx
sudo systemctl status php-fpm
sudo systemctl status smarteduconnect-queue.service

# Check ports
sudo netstat -tulpn | grep LISTEN

# Should see:
# Port 8080: nginx (SmartEduConnect backend)
```

**Test in browser:**
1. https://smarteduconnect.com (frontend)
2. https://smarteduconnect.com:8080 (backend API)

---

## Troubleshooting

### Check logs
```bash
# Nginx
sudo tail -f /var/log/nginx/error.log

# Laravel
tail -f /var/www/smarteduconnect/backend/storage/logs/laravel.log

# PHP-FPM
sudo tail -f /var/log/php-fpm/www-error.log

# Queue worker
sudo journalctl -u smarteduconnect-queue.service -f
```

### Common issues

**PHP-FPM socket not found:**
```bash
# Find the socket
sudo find /var/run -name "*php*"
# Update nginx config with correct path
```

**Permission denied:**
```bash
sudo chown -R nginx:nginx /var/www/smarteduconnect/backend/storage
sudo chmod -R 775 /var/www/smarteduconnect/backend/storage
```

**Clear Laravel cache:**
```bash
cd /var/www/smarteduconnect/backend
php artisan cache:clear
php artisan config:clear
php artisan config:cache
```

---

## Final Port Layout

```
Port 80/443: Nginx
  ├─ Existing Django/React project
  ├─ Existing Next.js project
  └─ SmartEduConnect frontend (smarteduconnect.com)

Port 3000: Next.js
Port 8000: Nginx → Django
Port 8001: Django backend
Port 8080: SmartEduConnect backend API ← NEW
Port 5432: PostgreSQL
Port 6379/6380: Redis/Valkey
```

All projects running independently without conflicts! 🎉
