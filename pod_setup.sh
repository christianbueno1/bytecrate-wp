#!/bin/bash

set -e

# Parse arguments
REMOVE_VOLUME=false
REMOVE_POD=false
for arg in "$@"; do
  case $arg in
    --rm-volume)
      REMOVE_VOLUME=true
      ;;
    --rm-pod)
      REMOVE_POD=true
      ;;
    *)
      echo "❌ Unknown argument: $arg"
      echo "Usage: $0 [--rm-volume] [--rm-pod]"
      exit 1
      ;;
  esac
done

# Load environment
ENV_FILE=".env.expanded"
if [ ! -f "$ENV_FILE" ]; then
  echo "❌ Environment file not found: $ENV_FILE"
  exit 1
fi
set -a
. "$ENV_FILE"
set +a

# 🧹 Stop and remove existing pod
if [ "$REMOVE_POD" = true ]; then
  echo "🧹 Checking for existing pod: $PODMAN_POD_WEB"
  if podman pod exists $PODMAN_POD_WEB; then
    echo "🛑 Stopping existing pod: $PODMAN_POD_WEB"
    podman pod stop $PODMAN_POD_WEB
    echo "🗑️ Removing existing pod: $PODMAN_POD_WEB"
    podman pod rm $PODMAN_POD_WEB
  fi
fi

# Remove existing volumes if --rm-volume is passed
if [ "$REMOVE_VOLUME" = true ]; then
  echo "🗑️ Removing existing volumes..."
  if podman volume exists $PODMAN_MARIADB_VOLUME; then
    podman volume rm $PODMAN_MARIADB_VOLUME
  fi
  if podman volume exists $PODMAN_WP_VOLUME; then
    podman volume rm $PODMAN_WP_VOLUME
  fi
fi

# Create persistent volumes
echo "📦 Creating persistent volumes..."
podman volume create $PODMAN_MARIADB_VOLUME
podman volume create $PODMAN_WP_VOLUME

# 📦 Create pod
echo "📦 Creating pod: $PODMAN_POD_WEB"
podman pod create --name $PODMAN_POD_WEB -p $WEB_SERVER_PORT:80 -p $PODMAN_MARIADB_PORT:3306

# 🗄️ Run MariaDB container
echo "🗄️  Starting MariaDB container: $PODMAN_MARIADB_CONTAINER"
podman run -d --name "$PODMAN_MARIADB_CONTAINER" \
  --pod "$PODMAN_POD_WEB" \
  -e MARIADB_ROOT_PASSWORD="$MARIADB_ROOT_PASSWORD" \
  -e MARIADB_DATABASE="$MARIADB_DB" \
  -e MARIADB_USER="$MARIADB_USER" \
  -e MARIADB_PASSWORD="$MARIADB_PASSWORD" \
  -v $PODMAN_MARIADB_VOLUME:/var/lib/mysql \
  "$PODMAN_MARIADB_IMAGE"

# ⏳ Wait for MariaDB to initialize
echo "⏳ Waiting for MariaDB to initialize..."
sleep 10

# build the wordpress image
echo "📦 Building WordPress image $PODMAN_WP_IMAGE ..."
# podman build --no-cache -t $PODMAN_WP_IMAGE -f Containerfile .
podman build -t $PODMAN_WP_IMAGE -f Containerfile .


# 🚀 Run WordPress container
echo "🚀 Starting WordPress container: $PODMAN_WP_CONTAINER"
podman run -d --name $PODMAN_WP_CONTAINER --pod $PODMAN_POD_WEB \
  -e WORDPRESS_DB_HOST="$PODMAN_MARIADB_CONTAINER:3306" \
  -e WORDPRESS_DB_NAME="$MARIADB_DB" \
  -e WORDPRESS_DB_USER="$MARIADB_USER" \
  -e WORDPRESS_DB_PASSWORD="$MARIADB_PASSWORD" \
  -v $PODMAN_WP_VOLUME:/var/www/html \
  $PODMAN_WP_IMAGE

echo "🎉 WordPress container started: $PODMAN_WP_CONTAINER"
echo "🌐 Visit http://localhost:$WEB_SERVER_PORT to access WordPress"