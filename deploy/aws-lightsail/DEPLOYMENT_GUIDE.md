# SmartEduConnect Deployment Guide
## Domain: smarteduconnect.com

### Architecture
- **Frontend**: https://smarteduconnect.com (port 80/443)
- **Backend API**: https://smarteduconnect.com:8080 (port 8080)

---

## Step 1: Create AWS Lightsail Instance

1. Go to AWS Lightsail Console
2. Create instance:
   - Platform: Linux/Unix
   - Blueprint: Ubuntu 22.04 LTS
   - Instance plan: At least 2GB RAM (recommended: 4GB)
   - Name: smarteduconnect-server
3. Wait for instance to be running
4. Note the public IP address

---

## Step 2: Configure Firewall

In Lightsail instance networking tab, add these rules:
- HTTP (80)
- HTTPS (443)
- Custom TCP (8080) - for backend API
- SSH (22)

---

## Step 3: Connect to Server

```bash
# Download the SSH key from Lightsail
# Then connect:
ssh -i /path/to/key.pem ubuntu@YOUR_LIGHTSAIL_IP
```

---

## Step 4: Bootstrap Server

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Clone repository
cd /tmp
git clone https://github.com/dileepkhanna/smarteduconnect_main_new.git
cd smarteduconnect_main_new

# Run bootstrap script
sudo bash deploy/aws-lightsail/bootstrap-server.sh
```

This installs:
- Nginx
- PHP 8.2 with extensions
- MySQL
- Node.js 20
- Composer

---

## Step 5: Setup MySQL Database

```bash
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

## Step 6: Deploy Application

```bash
# Copy repository to web directory
sudo mkdir -p /var/www/smarteduconnect-api
sudo cp -r /tmp/smarteduconnect_main_new/* /var/www/smarteduconnect-api/
sudo chown -R $USER:$USER /var/www/smarteduconnect-api

# Configure backend environment
cd /var/www/smarteduconnect-api/backend
cp .env.example .env
nano .env
```

Update `.env` with these values:
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

# S3 Storage (recommended for production)
FILESYSTEM_DISK=s3
AWS_ACCESS_KEY_ID=your_aws_key
AWS_SECRET_ACCESS_KEY=your_aws_secret
AWS_DEFAULT_REGION=ap-south-2
AWS_BUCKET=schoolwebapp1

# Queue
QUEUE_CONNECTION=database

# Session
SESSION_DRIVER=database
SESSION_SECURE_COOKIE=true

# CORS
ALLOWED_ORIGINS=https://smarteduconnect.com
```

---

## Step 7: Build and Deploy

```bash
cd /var/www/smarteduconnect-api

# Update frontend environment
cat > .env << EOF
VITE_API_BASE_URL=https://smarteduconnect.com:8080
EOF

# Run deployment script
bash deploy/aws-lightsail/deploy-app.sh
```

---

## Step 8: Configure Nginx

```bash
# Copy nginx configurations
sudo cp deploy/aws-lightsail/frontend-nginx.conf /etc/nginx/sites-available/smarteduconnect-frontend
sudo cp deploy/aws-lightsail/backend-nginx.conf /etc/nginx/sites-available/smarteduconnect-backend

# Enable sites
sudo ln -s /etc/nginx/sites-available/smarteduconnect-frontend /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/smarteduconnect-backend /etc/nginx/sites-enabled/

# Remove default site
sudo rm -f /etc/nginx/sites-enabled/default

# Test configuration
sudo nginx -t

# Reload nginx
sudo systemctl reload nginx
```

---

## Step 9: Setup Queue Worker

```bash
# Copy systemd service
sudo cp deploy/aws-lightsail/laravel-queue.service /etc/systemd/system/smarteduconnect-queue.service

# Enable and start service
sudo systemctl daemon-reload
sudo systemctl enable smarteduconnect-queue.service
sudo systemctl start smarteduconnect-queue.service

# Check status
sudo systemctl status smarteduconnect-queue.service
```

---

## Step 10: Configure DNS

In your domain registrar (GoDaddy, Namecheap, etc.):

1. Add A record:
   - Host: `@`
   - Points to: `YOUR_LIGHTSAIL_IP`
   - TTL: 3600

2. Add A record:
   - Host: `www`
   - Points to: `YOUR_LIGHTSAIL_IP`
   - TTL: 3600

Wait 5-30 minutes for DNS propagation.

---

## Step 11: Setup SSL Certificate

```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx -y

# Get SSL certificate
sudo certbot --nginx -d smarteduconnect.com -d www.smarteduconnect.com

# Follow prompts and select:
# - Enter email address
# - Agree to terms
# - Choose to redirect HTTP to HTTPS
```

For port 8080 SSL, you'll need to manually update the backend nginx config:

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
    
    # ... rest of config
}
```

Then reload:
```bash
sudo nginx -t
sudo systemctl reload nginx
```

---

## Step 12: Verify Deployment

1. Open browser and go to: `https://smarteduconnect.com`
2. Check that the frontend loads
3. Try logging in (API calls should go to port 8080)
4. Check browser console for any CORS errors
5. Test file upload to verify S3 integration

---

## Troubleshooting

### Check Nginx logs
```bash
sudo tail -f /var/log/nginx/error.log
```

### Check Laravel logs
```bash
tail -f /var/www/smarteduconnect-api/backend/storage/logs/laravel.log
```

### Check queue worker
```bash
sudo systemctl status smarteduconnect-queue.service
sudo journalctl -u smarteduconnect-queue.service -f
```

### Clear Laravel cache
```bash
cd /var/www/smarteduconnect-api/backend
php artisan config:clear
php artisan cache:clear
php artisan route:clear
php artisan view:clear
```

### Restart services
```bash
sudo systemctl restart nginx
sudo systemctl restart php8.2-fpm
sudo systemctl restart smarteduconnect-queue.service
```

---

## Updating the Application

```bash
cd /var/www/smarteduconnect-api
git pull origin main
bash deploy/aws-lightsail/deploy-app.sh
sudo systemctl restart smarteduconnect-queue.service
```

---

## Security Checklist

- [ ] Strong MySQL password set
- [ ] `.env` file permissions: `chmod 600 backend/.env`
- [ ] Firewall configured (only ports 22, 80, 443, 8080)
- [ ] SSL certificates installed
- [ ] `APP_DEBUG=false` in production
- [ ] Regular backups configured
- [ ] S3 bucket permissions properly configured
- [ ] Database backups automated

---

## Support

For issues, check:
1. Nginx error logs
2. Laravel logs
3. PHP-FPM logs: `/var/log/php8.2-fpm.log`
4. System logs: `sudo journalctl -xe`
