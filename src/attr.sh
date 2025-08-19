#!/usr/bin/env sh
# This script is recursive by default
# Adapted from https://github.com/just-containers/s6-overlay/issues/146#issuecomment-256545379

set -e

# Global variables
readonly SCRIPT_NAME="$(basename "$0")"

# Print usage information
usage() {
    cat <<EOF
Usage: ${SCRIPT_NAME} TARGET_PATH RECURSIVE OWNERSHIP FMODE [DMODE]

Arguments:
    TARGET_PATH    Path to file or directory to modify
    RECURSIVE      true|false (recursion cannot be disabled - not implemented)
    OWNERSHIP      Owner in format user:group (e.g., root:root)
    FMODE          File permissions in octal (e.g., 0644) or 'false' to skip
    DMODE          Directory permissions in octal (e.g., 0755) or 'false' to skip [optional]

Examples:
    ${SCRIPT_NAME} /path/to/file true root:root 0644
    ${SCRIPT_NAME} /path/to/dir true root:root 0644 0755
    ${SCRIPT_NAME} /path/to/dir true root:root false 0755

Notes:
    - Script is recursive by default
    - Recursion cannot be disabled (not implemented)
    - Use 'false' for OWNERSHIP to skip ownership changes
    - Use 'false' for FMODE to skip file permission changes
    - Use 'false' for DMODE to skip directory permission changes
EOF
}

# Validate that a path exists
validate_path() {
    path="$1"
    if [ ! -e "${path}" ]; then
        printf "Error: Path '%s' does not exist\n" "${path}" >&2
        return 1
    fi
}

# Validate ownership format (user:group or just user)
validate_ownership() {
    ownership="${1}"
    if [ "${ownership}" = "false" ]; then
        return 0
    fi

    # Basic validation - check if it contains valid characters
    if ! echo "${ownership}" | grep -qE '^[a-zA-Z0-9_][a-zA-Z0-9_-]*(:([a-zA-Z0-9_][a-zA-Z0-9_-]*)?)?$'; then
        printf "Error: Invalid ownership format '%s'. Use format 'user:group' or 'user'\n" "${ownership}" >&2
        return 1
    fi
}

# Validate permission format (octal)
validate_permissions() {
    perms="${1:?}"
    type="${2:?}"

    if [ "${perms}" = "false" ]; then
        return 0
    fi

    # Check if it's a valid octal number (3 or 4 digits)
    if ! echo "${perms}" | grep -qE '^[0-7]{3,4}$'; then
        printf "Error: Invalid %s permissions '%s'. Use octal format (e.g., 0755, 644)\n" "${type}" "${perms}" >&2
        return 1
    fi
}

# Change ownership of files/directories
do_chown() {
    target_path="${1:?}"
    ownership="${2:?}"

    if [ "${ownership}" = "false" ]; then
        echo "Skipping ownership changes (OWNERSHIP=false)"
        return 0
    fi

    echo "Changing ownership to '${ownership}'..."

    if [ -f "${target_path}" ]; then
        chown -v "${ownership}" "${target_path}"
    else
        chown -hvR "${ownership}" "${target_path}"
    fi
}

# Change permissions of files/directories
do_chmod() {
    target_path="${1:?}"
    fmode="${2:?}"
    dmode="${3:?}"

    if [ "${fmode}" = "false" ] && [ "${dmode}" = "false" ]; then
        echo "Skipping permission changes (both FMODE and DMODE are false)"
        return 0
    fi

    # Handle file permissions
    if [ -f "${target_path}" ] && [ "${fmode}" != "false" ]; then
        echo "Setting file permissions to '${fmode}'..."
        chmod -v "${fmode}" "${target_path}"
        return 0
    fi

    # Handle directory permissions
    if [ -d "${target_path}" ]; then
        if [ "${fmode}" != "false" ]; then
            echo "Setting file permissions to '${fmode}' (recursively)..."
            find "${target_path}" -type f -exec chmod -v "${fmode}" {} \;
        fi

        if [ "${dmode}" != "false" ]; then
            echo "Setting directory permissions to '${dmode}' (recursively)..."
            find "${target_path}" -type d -exec chmod -v "${dmode}" {} \;
        elif [ "${fmode}" != "false" ]; then
            # If only FMODE is set for a directory, apply it to directories too
            echo "Setting directory permissions to '${fmode}' (recursively)..."
            find "${target_path}" -type d -exec chmod -v "${fmode}" {} \;
        fi
    fi
}

# Main function
main() {
    # Check for help flag
    if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
        usage
        return 0
    fi

    # Check argument count
    if [ $# -lt 4 ] || [ $# -gt 5 ]; then
        printf "Error: Invalid number of arguments\n" >&2
        echo "" >&2
        usage >&2
        return 1
    fi

    # Parse arguments
    target_path="${1:?}"
    recursive="${2:?}"
    ownership="${3:?}"
    fmode="${4:?}"
    dmode="${5:-false}"

    # Validate arguments
    if [ -z "${target_path}" ]; then
        echo "Error: TARGET_PATH cannot be empty" >&2
        return 1
    fi

    validate_path "${target_path}" || return 1
    validate_ownership "${ownership}" || return 1
    validate_permissions "${fmode}" "file" || return 1
    validate_permissions "${dmode}" "directory" || return 1

    # Warn about recursive mode
    if [ "${recursive}" = "false" ]; then
        echo "Warning: Disabling recursive mode is not supported yet" >&2
    fi

    echo "Processing: ${target_path}"
    echo "Ownership: ${ownership}"
    echo "File mode: ${fmode}"
    echo "Directory mode: ${dmode}"
    echo ""

    # Execute operations
    do_chown "${target_path}" "${ownership}"
    do_chmod "${target_path}" "${fmode}" "${dmode}"

    echo "Operation completed successfully"
}

# Run main function with all arguments
main "$@"