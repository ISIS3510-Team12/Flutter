#!/usr/bin/env bash

set -euo pipefail
set +x

if [ -z "${GOOGLE_SERVICES_JSON_BASE64:-}" ]; then
  echo "::error::GOOGLE_SERVICES_JSON_BASE64 is not configured."
  exit 1
fi

mkdir -p android/app

printf '%s' "$GOOGLE_SERVICES_JSON_BASE64" \
  | base64 --decode \
  > android/app/google-services.json