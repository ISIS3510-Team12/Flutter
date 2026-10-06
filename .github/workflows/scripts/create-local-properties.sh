#!/usr/bin/env bash

set -euo pipefail
set +x

ANDROID_SDK_PATH="${ANDROID_SDK_ROOT:-${ANDROID_HOME:-}}"
FLUTTER_SDK_PATH="${FLUTTER_ROOT:-}"

if [ -z "$ANDROID_SDK_PATH" ]; then
  echo "::error::Android SDK was not found on the runner."
  exit 1
fi

if [ -z "$FLUTTER_SDK_PATH" ]; then
  FLUTTER_EXECUTABLE="$(command -v flutter || true)"

  if [ -z "$FLUTTER_EXECUTABLE" ]; then
    echo "::error::Flutter was not found on the runner."
    exit 1
  fi

  FLUTTER_SDK_PATH="$(
    dirname "$(dirname "$(realpath "$FLUTTER_EXECUTABLE")")"
  )"
fi

if [ -z "${MAPS_API_KEY:-}" ]; then
  echo "::error::MAPS_API_KEY is not configured."
  exit 1
fi

printf '%s\n' \
  "sdk.dir=${ANDROID_SDK_PATH}" \
  "flutter.sdk=${FLUTTER_SDK_PATH}" \
  "flutter.buildMode=debug" \
  "flutter.versionName=1.0.0" \
  "flutter.versionCode=1" \
  "MAPS_API_KEY=${MAPS_API_KEY}" \
  > android/local.properties