#!/bin/bash
set -e

# Load environment
# ENV_FILE=".env"
# if [ ! -f "$ENV_FILE" ]; then
#   echo "❌ Environment file not found: $ENV_FILE"
#   exit 1
# fi
# set -a
# . "$ENV_FILE"
# set +a

# Install WordPress if not already installed
if [ ! -f /var/www/html/wp-config.php ]; then
  echo "📦 Installing WordPress..."
  su -s /bin/bash www-data -c "wp core download --allow-root"
  su -s /bin/bash www-data -c "wp config create --allow-root \
    --dbname=$MARIADB_DB \
    --dbuser=$MARIADB_USER \
    --dbpass=$MARIADB_PASSWORD \
    --dbhost=$PODMAN_MARIADB_CONTAINER \
    --path=/var/www/html"
  su -s /bin/bash www-data -c "wp db create --allow-root"
fi
echo "📦 Initializing WordPress..."
su -s /bin/bash www-data -c "wp core install \
  --url=$WP_URL \
  --title=$WP_TITLE \
  --admin_user=$WP_ADMIN_USER \
  --admin_password=$WP_ADMIN_PASSWORD \
  --admin_email=$WP_ADMIN_EMAIL \
"

# Update 'blog_public' option
echo "🔧 Updating 'blog_public' option..."
su -s /bin/bash www-data -c "wp option update blog_public 0"

# Ensure both themes are owned properly
# chown -R www-data:www-data /var/www/html/wp-content/themes/motta
# chown -R www-data:www-data /var/www/html/wp-content/themes/motta-child

# Activate the Motta Child theme
echo "🎨 Activating Motta Child theme..."
su -s /bin/bash www-data -c "wp theme activate motta-child"

exec "$@"
