#!/bin/bash

set -e

# Load environment
ENV_FILE=".env"
if [ ! -f "$ENV_FILE" ]; then
  echo "❌ Environment file not found: $ENV_FILE"
  exit 1
fi
set -a
. "$ENV_FILE"
set +a

# Variables
# DOMAIN_NAME=bestbuy.christianbueno.tech
# WP_PORT=8080
# ROOT=/var/www/${DOMAIN_NAME}/public_html


# sudo dnf install nginx podman firewalld -y
# sudo systemctl enable --now nginx firewalld
# sudo firewall-cmd --permanent --add-service=http
# sudo firewall-cmd --permanent --add-service=https
# sudo firewall-cmd --reload


# create nginx configuration file, a proxy for the wordpress container
echo "🔧 Creating Nginx configuration file for ${DOMAIN_NAME}..."
cat << EOF | sudo tee /etc/nginx/conf.d/${DOMAIN_NAME}.conf > /dev/null
server {
  listen 80;
  server_name ${DOMAIN_NAME};
  #avoid rejecting files too large
  client_max_body_size 64M;
  # client_max_body_size 100M;

  location / {
    proxy_pass http://localhost:$WP_PORT;
    proxy_http_version 1.1;
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
  }

  access_log /var/log/nginx/${DOMAIN_NAME}_access.log;
  error_log  /var/log/nginx/${DOMAIN_NAME}_error.log;
}
EOF

# on fedora, you need to run this command when setup the fedora server
# You need to set the correct SELinux context for your Nginx configuration file.
echo "🔒 Setting SELinux context for Nginx configuration file..."
# sudo chcon -t httpd_sys_rw_content_t /etc/nginx/conf.d/${DOMAIN_NAME}.conf
# sudo chcon -t httpd_config_t /etc/nginx/conf.d/${DOMAIN_NAME}.conf
# sudo restorecon -v /etc/nginx/conf.d/${DOMAIN_NAME}.conf
#
# ok
# sudo semanage fcontext -a -t httpd_config_t "/etc/nginx/conf.d/${DOMAIN_NAME}.conf"
# sudo restorecon -v /etc/nginx/conf.d/${DOMAIN_NAME}.conf
#
# check the context
echo "🔍 Checking SELinux context for Nginx configuration file..."
ls -Z /etc/nginx/conf.d/${DOMAIN_NAME}.conf



# test the nginx configuration
echo "🔍 Testing Nginx configuration..."
sudo nginx -t
# reload nginx
echo "🔄 Reloading Nginx..."
sudo systemctl reload nginx

# display message: Nginx configuration file ready
echo "✅ Nginx configuration file ready: /etc/nginx/conf.d/${DOMAIN_NAME}.conf"