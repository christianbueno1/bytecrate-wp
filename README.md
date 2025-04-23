# Composa WordPress project

### Environment variables
- .env.example
- cp .env.example .env

### The shell script
```bash
./pod_setup.sh

# This will remove the volumes created by the script
./pod_setup.sh --rm-volumes

```

## SSL
### 🔍 2. Test your Nginx config
Make sure your Nginx config is valid before proceeding:

```bash
sudo nginx -t && sudo systemctl reload nginx
```

### 🔐 3. Run Certbot for your domain
```bash
sudo certbot --nginx -d wordpress.christianbueno.tech -d www.wordpress.christianbueno.tech

```

### 🔁 4. (Optional but recommended) Auto-renewal test
Let’s Encrypt certs last 90 days, but Certbot sets up automatic renewal via systemd.

Test it manually:

```bash
sudo certbot renew --dry-run

```

### Containerfile
```bash
# 413 Request Entity Too Large
# file upload size limit
vim /usr/local/etc/php/php.ini

```
