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

# install wp-cli
if ! command -v wp &> /dev/null
then
    echo "❌ wp-cli could not be found, please install it first."
    exit 1
fi
# install it and add x mode
echo "📦 Installing WP-CLI"
curl -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && chmod +x /usr/local/bin/wp
# check wp is working
if ! wp --info &> /dev/null
then
  echo "❌ wp-cli could not be found, please install it first."
  exit 1
else
  echo "✅ wp-cli is installed and working."
fi

# use wp-cli to enter the intial WordPress setup values
# wp core install \
# --url="$WP_URL" \
# --title="$WP_TITLE" \
# --admin_user="$WP_ADMIN_USER" \
# --admin_password="$WP_ADMIN_PASSWORD" \
# --admin_email="$WP_ADMIN_EMAIL"

# sudo -u USER -i -- wp <command>
#
sudo -u www-data wp core install \
--url=bytecrate.christianbueno.tech \
--title=ByteCrate \
--admin_user="chris" \
--admin_password="maGazine1!" \
--admin_email="chmabuen@espol.edu.ec"

wp core install \
--url=bytecrate.christianbueno.tech \
--title=ByteCrate \
--admin_user="chris" \
--admin_password="maGazine1!" \
--admin_email="chmabuen@espol.edu.ec" \
--allow-root



# inside the container
su -s /bin/bash www-data -c "wp core install \
  --url=bytecrate.christianbueno.tech \
  --title=ByteCrate \
  --admin_user='chris' \
  --admin_password='maGazine1!' \
  --admin_email='chmabuen@espol.edu.ec'"

su -s /bin/bash www-data -c "wp option update blog_public 0"

# If you want to reinstall for testing, you can do a clean-up with:
su -s /bin/bash www-data -c "wp db reset --yes"

# This passes those variables as container environment variables, not as a .env file written to the container's file system.
# --env-file .env

podman run --rm -it --name wp-test --pod bytecrate-pod \
  --env-file .env \
  -e WORDPRESS_DB_HOST=byecrate-mariadb:3306 \
  -e WORDPRESS_DB_USER=chris \
  -e WORDPRESS_DB_PASSWORD='maGazine1!' \
  -e WORDPRESS_DB_NAME=vendor-db \
  -v bytecrate-wordpress-data:/var/www/html \
  docker.io/christianbueno1/wordpress:6.8-php8.3-large-upload-soap bash

podman run -d --name bytecrate-wordpress --pod bytecrate-pod \
  --env-file .env.expanded \
  -e WORDPRESS_DB_HOST=byecrate-mariadb:3306 \
  -e WORDPRESS_DB_USER=chris \
  -e WORDPRESS_DB_PASSWORD='maGazine1!' \
  -e WORDPRESS_DB_NAME=vendor-db \
  -v bytecrate-wordpress-data:/var/www/html \
  docker.io/christianbueno1/wordpress:6.8-php8.3-large-upload-soap


podman exec -it bytecrate-wordpress bash
podman exec -it bytecrate-wordpress env