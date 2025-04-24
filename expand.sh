#!/bin/bash
set -euo pipefail

# VARIABLES
ENV_FILE=".env"

# Cargar variables desde $ENV_FILE
echo "📦 Cargando variables desde $ENV_FILE"
while IFS='=' read -r key value; do
  # Omitir líneas vacías o comentarios
  [[ -z "$key" || "$key" == \#* ]] && continue

  # Eliminar comillas envolventes si las hay
  value="${value%\"}"
  value="${value#\"}"
  value="${value%\'}"
  value="${value#\'}"

  export "$key=$value"
done < $ENV_FILE

# Expansión con envsubst
echo "⚙️  Expandiendo variables..."
envsubst < $ENV_FILE > .env.expanded
echo "✅ Archivo .env.expanded generado."
