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

# Prompt for ADMIN_PASSWORD
read -s -p "Enter ADMIN_PASSWORD: " ADMIN_PASSWORD
echo

# echo "🔄 Updating system packages..."
# Update system packages
# echo "$ADMIN_PASSWORD" | sudo -S dnf update -y

echo "📦 Installing Certbot and the Nginx plugin..."
# Install Certbot and the Nginx plugin
echo "$ADMIN_PASSWORD" | sudo -S dnf install -y certbot python3-certbot-nginx

echo "🔐 Obtaining SSL certificate for the domain using Certbot with Nginx plugin..."
# Obtain SSL certificate for the domain using Certbot with Nginx plugin
if ! echo "$ADMIN_PASSWORD" | sudo -S certbot --nginx \
-d $DOMAIN_NAME \
--non-interactive \
--agree-tos \
--email $ADMIN_EMAIL \
--redirect; then
  echo "❌ Failed to obtain SSL certificate for $DOMAIN_NAME. Please check the logs for details."
  exit 1
fi

# it take some time to test
# echo "🛠️ Testing automatic renewal..."
# Test automatic renewal
# echo "$ADMIN_PASSWORD" | sudo -S certbot renew --dry-run

echo "✅ SSL setup complete for $DOMAIN_NAME 🎉"