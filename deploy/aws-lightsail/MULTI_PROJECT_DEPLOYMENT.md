# SmartEduConnect Deployment on Existing Lightsail Instance
## Deploying alongside Django+React and Next.js projects

### Current Setup
Your instance already has:
- Django + React project
- Next.js project
- Nginx, Python, Node.js already installed

### New Configuration for SmartEduConnect
- **Frontend**: https://smarteduconnect.com (port 80/443)
- **Backend API**: https://smarteduconnect.com:8080 (port 8080)

---

## Step 1: Check Current Setup

```bash
# Check what's currently running
sudo systemctl status nginx
sudo netstat -tulpn | grep LISTEN

# Check existing nginx sites
ls -la /etc/nginx/sites-enabled/

# Check PHP version (if installed)
php -v
```

---

## Step 2: Install PHP 8.2 (if not already installed)

```bash
# Check if PHP is installed
php -v

# If not installed or version is old:
sudo add-apt-repository -y ppa:ondrej/php
sudo apt update
sudo apt install -y \
  php8.2 \
  php8.2-cli \
  php8.2-common \
  php8.2-curl \
  php8.2-fpm \
  php8.2-mbstring \
  php8.2-mysql \
  php8.2-xml \
  php8.2-zip \
  php8.2-bcmath \
  php8.2-intl \
  php8.2-gd

# Enable PHP-FPM
sudo systemctl enable --now php8.2-fpm
```

---

## Step 3: Install Composer (if not already installed)

```bash
# Check if composer exists
composer --version

# If not installed:
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
```

---

## Step 4: Setup MySQL Database

```bash
# Check if MySQL is running
sudo systemctl status mysql

# If not installed:
# sudo apt install mysql-server -y

# Create database
sudo mysql
```

In MySQL console:
```sql
CREATE DATABASE smarteduconnect CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'smarteduconnect'@'localhost' IDENTIFIED BY 'YOUR_SECURE_PASSWORD';
GRANT ALL PRIVILEGES ON smarteduconnect.* TO 'smarteduconnect'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

---

## Step 5: Deploy SmartEduConnect Application

```bash
# Create directory for the new project
sudo mkdir -p /var/www/smarteduconnect-api
sudo mkdir -p /var/www/smarteduconnect-frontend

# Clone repository
cd /tmp
git clone https://github.com/dileepkhanna/smarteduconnect_main_new.git
cd smarteduconnect_main_new

# Copy to web directory
sudo cp -r * /var/www/smarteduconnect-api/
sudo chown -R $USER:$USER /var/www/smarteduconnect-api

# Configure backend environment
cd /var/www/smarteduconnect-api/backend
cp .env.example .env
nano .env
```

Update `.env`:
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

---

## Step 6: Build Application

```bash
cd /var/www/smarteduconnect-api

# Create frontend .env
cat > .env << EOF
VITE_API_BASE_URL=https://smarteduconnect.com:8080
EOF

# Install dependencies and build
npm install
npm run build

# Copy frontend build
sudo rsync -av --delete dist/ /var/www/smarteduconnect-frontend/dist/

# Install backend dependencies
cd backend
composer install --no-dev --optimize-autoloader

# Generate key and run migrations
php artisan key:generate --force
php artisan migrate --force
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Set permissions
sudo chown -R www-data:www-data storage bootstrap/cache
sudo chmod -R 775 storage bootstrap/cache
```

---

## Step 7: Configure Nginx (Without Conflicts)

Create frontend config:
```bash
sudo nano /etc/nginx/sites-available/smarteduconnect-frontend
```

Add:
```nginx
server {
    listen 80;
    server_name smarteduconnect.com www.smarteduconnect.com;

    root /var/www/smarteduconnect-frontend/dist;
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
sudo nano /etc/nginx/sites-available/smarteduconnect-backend
```

Add:
```nginx
server {
    listen 8080;
    server_name smarteduconnect.com www.smarteduconnect.com;

    root /var/www/smarteduconnect-api/backend/public;
    index index.php index.html;

    client_max_body_size 20m;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.2-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
```

Enable sites:
```bash
# Enable new sites
sudo ln -s /etc/nginx/sites-available/smarteduconnect-frontend /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/smarteduconnect-backend /etc/nginx/sites-enabled/

# Test configuration (IMPORTANT - check for conflicts)
sudo nginx -t

# If test passes, reload
sudo systemctl reload nginx
```

---

## Step 8: Open Port 8080 in Lightsail Firewall

1. Go to AWS Lightsail Console
2. Select your instance
3. Go to "Networking" tab
4. Under "Firewall", click "Add rule"
5. Add:
   - Application: Custom
   - Protocol: TCP
   - Port: 8080

---

## Step 9: Setup Queue Worker (Unique Service Name)

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
User=www-data
Group=www-data
Restart=always
RestartSec=5
ExecStart=/usr/bin/php /var/www/smarteduconnect-api/backend/artisan queue:work --sleep=3 --tries=3 --max-time=3600

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

## Step 10: Configure DNS

In your domain registrar:

1. Add A record:
   - Host: `smarteduconnect` or `@` (if using root domain)
   - Points to: `YOUR_LIGHTSAIL_IP`
   - TTL: 3600

2. Add A record (optional):
   - Host: `www.smarteduconnect`
   - Points to: `YOUR_LIGHTSAIL_IP`
   - TTL: 3600

---

## Step 11: Setup SSL Certificate

```bash
# Install Certbot (if not already installed)
sudo apt install certbot python3-certbot-nginx -y

# Get SSL certificate for smarteduconnect.com
sudo certbot --nginx -d smarteduconnect.com -d www.smarteduconnect.com

# Follow prompts
```

For port 8080 SSL, manually update backend config:
```bash
sudo nano /etc/nginx/sites-available/smarteduconnect-backend
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

    root /var/www/smarteduconnect-api/backend/public;
    index index.php index.html;

    client_max_body_size 20m;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.2-fpm.sock;
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

## Step 12: Verify All Projects Are Running

```bash
# Check all nginx sites
ls -la /etc/nginx/sites-enabled/

# Check what's listening on which ports
sudo netstat -tulpn | grep LISTEN

# Check all services
sudo systemctl status nginx
sudo systemctl status php8.2-fpm
sudo systemctl status smarteduconnect-queue.service

# Check nginx error logs
sudo tail -f /var/log/nginx/error.log
```

---

## Port Allocation Summary

Make sure your projects don't conflict:

| Project | Frontend Port | Backend Port | Domain |
|---------|--------------|--------------|---------|
| Django+React | ? | ? | ? |
| Next.js | ? | ? | ? |
| SmartEduConnect | 80/443 | 8080 | smarteduconnect.com |

---

## Troubleshooting

### Port Conflicts
```bash
# Check what's using each port
sudo lsof -i :80
sudo lsof -i :443
sudo lsof -i :8080
sudo lsof -i :3000
sudo lsof -i :8000
```

### Nginx Configuration Conflicts
```bash
# Test nginx config
sudo nginx -t

# Check all enabled sites
cat /etc/nginx/sites-enabled/*

# Disable a site if needed
sudo rm /etc/nginx/sites-enabled/site-name
sudo systemctl reload nginx
```

### Check Laravel Logs
```bash
tail -f /var/www/smarteduconnect-api/backend/storage/logs/laravel.log
```

### Check PHP-FPM
```bash
sudo systemctl status php8.2-fpm
sudo tail -f /var/log/php8.2-fpm.log
```

### Restart Services
```bash
sudo systemctl restart nginx
sudo systemctl restart php8.2-fpm
sudo systemctl restart smarteduconnect-queue.service
```

---

## Resource Monitoring

With multiple projects, monitor resources:

```bash
# Check memory usage
free -h

# Check disk usage
df -h

# Check CPU usage
top

# Check running processes
ps aux | grep -E 'nginx|php|python|node'
```

---

## Updating SmartEduConnect

```bash
cd /var/www/smarteduconnect-api
git pull origin main

# Rebuild frontend
npm install
npm run build
sudo rsync -av --delete dist/ /var/www/smarteduconnect-frontend/dist/

# Update backend
cd backend
composer install --no-dev --optimize-autoloader
php artisan migrate --force
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Restart queue worker
sudo systemctl restart smarteduconnect-queue.service
```

---

## Quick Reference

### SmartEduConnect URLs
- Frontend: https://smarteduconnect.com
- Backend API: https://smarteduconnect.com:8080
- API Health: https://smarteduconnect.com:8080/api/health (if you create one)

### Important Paths
- Frontend: `/var/www/smarteduconnect-frontend/dist`
- Backend: `/var/www/smarteduconnect-api/backend`
- Logs: `/var/www/smarteduconnect-api/backend/storage/logs/laravel.log`
- Nginx Config: `/etc/nginx/sites-available/smarteduconnect-*`

### Important Commands
```bash
# Restart all SmartEduConnect services
sudo systemctl restart php8.2-fpm nginx smarteduconnect-queue.service

# Clear Laravel cache
cd /var/www/smarteduconnect-api/backend
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear

# Check logs
sudo tail -f /var/log/nginx/error.log
tail -f /var/www/smarteduconnect-api/backend/storage/logs/laravel.log
```
