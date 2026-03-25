# Pre-Deployment Checklist for Existing Lightsail Instance

Before deploying SmartEduConnect, run these commands to understand your current setup:

## 1. Check Current Ports in Use

```bash
sudo netstat -tulpn | grep LISTEN
```

This shows what's listening on which ports. Look for:
- Port 80 (HTTP)
- Port 443 (HTTPS)
- Port 3000 (common for Next.js)
- Port 8000 (common for Django)
- Port 8080 (we want to use this for SmartEduConnect backend)

## 2. Check Nginx Configuration

```bash
# List all enabled sites
ls -la /etc/nginx/sites-enabled/

# View each site configuration
cat /etc/nginx/sites-enabled/*
```

Note down:
- Which domains are configured
- Which ports they use
- Which directories they serve from

## 3. Check Running Services

```bash
# Check all systemd services
sudo systemctl list-units --type=service --state=running | grep -E 'nginx|gunicorn|node|pm2|django'

# Check PM2 processes (if using PM2 for Node.js)
pm2 list

# Check Python/Django processes
ps aux | grep python

# Check Node.js processes
ps aux | grep node
```

## 4. Check Installed Software

```bash
# Check PHP
php -v

# Check Python
python3 --version

# Check Node.js
node -v
npm -v

# Check MySQL/PostgreSQL
mysql --version
psql --version

# Check Nginx
nginx -v

# Check Composer
composer --version
```

## 5. Check Disk Space

```bash
df -h
```

Make sure you have at least 2-3 GB free for SmartEduConnect.

## 6. Check Memory Usage

```bash
free -h
```

## 7. Check Current Project Directories

```bash
ls -la /var/www/
ls -la /home/ubuntu/
```

## 8. Check Firewall Rules

In AWS Lightsail Console:
1. Go to your instance
2. Click "Networking" tab
3. Check which ports are open

## 9. Check Domain DNS

```bash
# Check current DNS records
nslookup smarteduconnect.com
dig smarteduconnect.com
```

---

## Recommended Port Allocation

Based on common setups:

| Service | Typical Port | Recommendation |
|---------|-------------|----------------|
| Django Backend | 8000 | Keep as is |
| Next.js | 3000 or 80/443 | Keep as is |
| SmartEduConnect Frontend | 80/443 | Use subdomain or different domain |
| SmartEduConnect Backend | 8080 | Safe to use |

---

## Option 1: Use Subdomain (Recommended)

If your existing projects use the main domain:
- Existing: `yourdomain.com` → Django/Next.js
- SmartEduConnect: `smarteduconnect.com` → New project

This is the cleanest approach with no conflicts.

---

## Option 2: Use Different Ports

If you want everything on one domain:
- Port 80/443: Existing project
- Port 8080: SmartEduConnect frontend
- Port 8081: SmartEduConnect backend

Update nginx configs accordingly.

---

## Option 3: Use Nginx Reverse Proxy with Path-Based Routing

Configure nginx to route based on URL path:
- `yourdomain.com/` → Existing project
- `yourdomain.com/smartedu/` → SmartEduConnect

This requires modifying SmartEduConnect's base URL configuration.

---

## After Running These Checks

Share the output of:
1. `sudo netstat -tulpn | grep LISTEN`
2. `ls -la /etc/nginx/sites-enabled/`
3. Current domains and how they're configured

This will help determine the best deployment strategy without breaking existing projects.
