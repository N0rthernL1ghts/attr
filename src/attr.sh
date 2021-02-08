#!/usr/bin/env sh

OWNERSHIP=${1:-}
CHMOD=${2:-}
TARGET=${3:-}

chown -hR "${OWNERSHIP}" "${TARGET}"
chmod -R "${CHMOD}" "${TARGET}"
