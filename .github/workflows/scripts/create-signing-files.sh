#!/usr/bin/env bash

set -euo pipefail
set +x

REQUIRED_VARIABLES=(
  ANDROID_KEYSTORE_BASE64
  ANDROID_KEYSTORE_PASSWORD
  ANDROID_KEY_ALIAS
  ANDROID_KEY_PASSWORD
)

for VARIABLE_NAME in "${REQUIRED_VARIABLES[@]}"; do
  if [ -z "${!VARIABLE_NAME:-}" ]; then
    echo "::error::${VARIABLE_NAME} is not configured."
    exit 1
  fi
done

printf '%s' "$ANDROID_KEYSTORE_BASE64" \
  | base64 --decode \
  > android/app/juggle-upload-keystore.jks

chmod 600 android/app/juggle-upload-keystore.jks

printf '%s\n' \
  "storePassword=${ANDROID_KEYSTORE_PASSWORD}" \
  "keyPassword=${ANDROID_KEY_PASSWORD}" \
  "keyAlias=${ANDROID_KEY_ALIAS}" \
  "storeFile=juggle-upload-keystore.jks" \
  > android/key.properties

chmod 600 android/key.properties
