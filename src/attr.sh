#!/usr/bin/env sh
# This script is recursive by default
# Adapted from https://github.com/just-containers/s6-overlay/issues/146#issuecomment-256545379

if [ $# -eq 0 ]; then
	echo "No arguments supplied"
	echo ""
	echo "Usage: "
	echo "  attr /path/to true||false root||root:root 0777||false [0777||false]"
	echo "Example: "
	echo "  attr /path/to true root:root 0777 0777"
	echo ""
	echo "Script is recursive by default, and recursion cannot be disabled (not implemented)"
	exit 1
fi

# Arguments. Simple handling.
TARGET_PATH=${1:-}
RECURSIVE=${2:-}
OWNERSHIP=${3:-}
FMODE=${4:-}
DMODE=${5:-}

# Always required
if [ -z "${TARGET_PATH}" ]; then
	echo "InvalidArgumentError: Missing target path"
	exit 1
fi

# Always required
if [ -z "${OWNERSHIP}" ]; then
	echo "InvalidArgumentError: Missing ownership"
	exit 1
fi

# This is always required, regardless of target type, but it can be false to indicate only directory handling
if [ -z "${FMODE}" ]; then
	echo "InvalidArgumentError: Missing file chmod"
	exit 1
fi

# Argument is here even though not implemented, for the sake of compatibility with skarnet/s6 fix-attrs.d
if [ "${RECURSIVE}" = false ]; then
	echo "Warning: Disabling recursive mode is not supported yet"
fi

doChown() {
	if [ "${OWNERSHIP}" = false ]; then
		return 0
	fi

	if [ "${FMODE}" = false ]; then
		find "${TARGET_PATH}" -type d -exec chown "${OWNERSHIP}" {} \;
		return $?
	fi

	if [ -f "${TARGET_PATH}" ]; then
		chown "${OWNERSHIP}" "${TARGET_PATH}"
		return $?
	fi

	chown -hR "${OWNERSHIP}" "${TARGET_PATH}"
	return $?
}

doChmod() {
	if [ "${FMODE}" = false ] && [ "${DMODE}" = false ]; then
		return 0
	fi

	if [ -f "${TARGET_PATH}" ] && [ "${FMODE}" != false ]; then
		chmod "${FMODE}" "${TARGET_PATH}"
		return $?
	fi

	if [ "${DMODE}" != false ]; then
		find "${TARGET_PATH}" -type d -exec chmod "${DMODE}" {} \;
	fi
}

doChown
doChmod
