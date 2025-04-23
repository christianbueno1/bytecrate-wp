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
# PODMAN_WP_IMAGE="docker.io/christianbueno1/wordpress:6.8-php8.3-large-upload"
# echo $PODMAN_WP_IMAGE
# build the wordpress image
echo "📦 Building WordPress image $PODMAN_WP_IMAGE ..."
podman build -t $PODMAN_WP_IMAGE -f Containerfile .