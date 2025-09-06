#!/bin/bash
set -euo pipefail

# Direct rclone mount wrapper using environment variables
# Usage: mount-remote.sh <remote_type> <remote_path> <mount_point> [rclone_options...]

# Check arguments
if [ $# -lt 3 ]; then
    echo "Usage: $0 <remote_type> <remote_path> <mount_point> [rclone_options...]"
    echo "   or: $0 <remote_name> <remote_type> <remote_path> <mount_point> [rclone_options...]"
    echo ""
    echo "Remote path can be 'auto' to use RCLONE_CONFIG_<NAME>_PATH env var"
    echo ""
    echo "Examples:"
    echo "  $0 b2 auto /mnt/b2                          # Uses RCLONE_CONFIG_B2_REMOTE_PATH"
    echo "  $0 b2 :my-bucket /mnt/b2                    # Direct bucket name"
    echo "  $0 myb2 b2 auto /mnt/b2                     # Uses RCLONE_CONFIG_MYB2_PATH"
    echo "  $0 ftp auto /mnt/ftp                        # Uses RCLONE_CONFIG_FTP_REMOTE_PATH"
    echo ""
    echo "Set credentials and path via environment variables:"
    echo "  RCLONE_CONFIG_<REMOTE_NAME>_TYPE=<type>"
    echo "  RCLONE_CONFIG_<REMOTE_NAME>_PATH=<path>"
    echo "  RCLONE_CONFIG_<REMOTE_NAME>_HOST=<host>"
    echo "  etc..."
    exit 1
fi

# Parse arguments - detect if remote name is provided
if [[ "$2" == "auto" ]] || [[ "$2" =~ ^: ]] || [[ "$2" == /* ]]; then
    # Format: <type> <path> <mount> [options...]
    REMOTE_TYPE="$1"
    REMOTE_NAME="${REMOTE_TYPE}_remote"
    REMOTE_PATH="$2"
    MOUNT_POINT="$3"
    shift 3
else
    # Format: <name> <type> <path> <mount> [options...]
    REMOTE_NAME="$1"
    REMOTE_TYPE="$2"
    REMOTE_PATH="$3"
    MOUNT_POINT="$4"
    shift 4
fi
EXTRA_OPTIONS="$@"

# Expand "auto" into actual path from environment variable
if [[ "$REMOTE_TYPE" == "ftp" ]]; then
    REMOTE_NAME=":ftp:"
fi

if [[ "$REMOTE_PATH" == "auto" ]]; then
    # Uppercase and replace dashes with underscores for env var naming
    ENV_REMOTE_NAME=$(echo "$REMOTE_NAME" | tr '[:lower:]-' '[:upper:]_')
    ENV_PATH_VAR="RCLONE_CONFIG_${ENV_REMOTE_NAME}_PATH"
    if [[ -z "${!ENV_PATH_VAR:-}" ]]; then
        echo "Error: Environment variable $ENV_PATH_VAR is not set."
        exit 1
    fi
    REMOTE_PATH="${!ENV_PATH_VAR}"
fi

# Create mount directory if it doesn't exist
mkdir -p "$MOUNT_POINT"

# Build the rclone command - use remote name directly
RCLONE_CMD="/opt/rclone mount ${REMOTE_NAME}${REMOTE_PATH} ${MOUNT_POINT}"

# Add backend-specific optimizations
case "$REMOTE_TYPE" in
    b2)
        # B2 optimized settings - handles many transfers well
        RCLONE_CMD="$RCLONE_CMD --read-only --transfers 20 --dir-cache-time 720h --vfs-cache-mode full --checkers 8"
        ;;
    ftp)
        # FTP optimized settings - more conservative
        RCLONE_CMD="$RCLONE_CMD --read-only --transfers 4 --dir-cache-time 24h --vfs-cache-mode full --tpslimit 10"
        ;;
    sftp)
        # SFTP settings - similar to FTP but can handle more
        RCLONE_CMD="$RCLONE_CMD --read-only --transfers 8 --dir-cache-time 48h --vfs-cache-mode full --tpslimit 20"
        ;;
    *)
        # Generic defaults for other backends
        RCLONE_CMD="$RCLONE_CMD --read-only --dir-cache-time 168h --vfs-cache-mode full"
        ;;
esac

# Add any extra options passed as arguments
if [ -n "$EXTRA_OPTIONS" ]; then
    RCLONE_CMD="$RCLONE_CMD $EXTRA_OPTIONS"
fi

echo "Mounting ${REMOTE_TYPE}${REMOTE_PATH} to $MOUNT_POINT"
echo "Command: $RCLONE_CMD"

# Execute rclone mount in foreground
exec $RCLONE_CMD
