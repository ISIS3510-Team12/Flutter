#!/usr/bin/env bash

set -euo pipefail
set +x

REQUIRED_VARIABLES=(
  APIKEY
  APPID
  MESSAGINGSENDERID
  PROJECTID
  STORAGEBUCKET
  API_URL
)

for VARIABLE_NAME in "${REQUIRED_VARIABLES[@]}"; do
  if [ -z "${!VARIABLE_NAME:-}" ]; then
    echo "::error::${VARIABLE_NAME} is not configured."
    exit 1
  fi
done

printf '%s\n' \
  "APIKEY=${APIKEY}" \
  "APPID=${APPID}" \
  "MESSAGINGSENDERID=${MESSAGINGSENDERID}" \
  "PROJECTID=${PROJECTID}" \
  "STORAGEBUCKET=${STORAGEBUCKET}" \
  "API_URL=${API_URL}" \
  > .env