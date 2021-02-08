#!/usr/bin/env sh
# This script is recursive by default

# Arguments
TARGET_PATH=${1:-}
OWNERSHIP=${2:-}
FMODE=${3:-}
DMODE=${4:-}

if [ -z "${TARGET_PATH}" ]; then
  echo "InvalidArgumentError: Missing target path"
  exit 1
fi

if [ -z "${OWNERSHIP}" ]; then
  echo "InvalidArgumentError: Missing ownership"
  exit 1
fi

if [ -z "${FMODE}" ]; then
  echo "InvalidArgumentError: Missing target path"
  exit 1
fi

if [ -z "${DMODE}" ]; then
  echo "InvalidArgumentError: Missing target path"
  exit 1
fi

chown -hR "${OWNERSHIP}" "${TARGET_PATH}"
chmod -R "${FMODE}" "${TARGET_PATH}"
find "${TARGET_PATH}" -type d -exec chmod "${DMODE}" {} \;
