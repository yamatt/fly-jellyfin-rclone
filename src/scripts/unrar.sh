#!/bin/bash
set -euo pipefail

echo "[$(date)] Starting unrar mount script" >&2
echo "[$(date)] PID: $$" >&2

# Check if FUSE is available
if [ ! -c /dev/fuse ]; then
    echo "[$(date)] ERROR: /dev/fuse not available" >&2
    exit 1
fi
echo "[$(date)] /dev/fuse is available" >&2

# Wait for source directory to be ready and have content
echo "[$(date)] Waiting for /mnt/ftp to be ready..." >&2
MAX_WAIT=60
COUNTER=0
while [ $COUNTER -lt $MAX_WAIT ]; do
    if [ -d /mnt/ftp ]; then
        # Check if it's actually mounted (not just an empty directory)
        if mountpoint -q /mnt/ftp 2>/dev/null; then
            echo "[$(date)] /mnt/ftp is mounted" >&2
            # Wait a bit more for content to appear
            sleep 2
            if [ -n "$(ls -A /mnt/ftp 2>/dev/null)" ]; then
                echo "[$(date)] /mnt/ftp has content" >&2
                break
            else
                echo "[$(date)] /mnt/ftp is mounted but empty, waiting..." >&2
            fi
        else
            echo "[$(date)] /mnt/ftp exists but is not mounted, waiting..." >&2
        fi
    else
        echo "[$(date)] /mnt/ftp does not exist yet, waiting..." >&2
    fi
    sleep 1
    COUNTER=$((COUNTER + 1))
done

if [ $COUNTER -ge $MAX_WAIT ]; then
    echo "[$(date)] ERROR: Timeout waiting for /mnt/ftp to be ready" >&2
    exit 1
fi

echo "[$(date)] Source directory contents:" >&2
ls -la /mnt/ftp >&2

# Create mount point
mkdir -p /mnt/unrar
echo "[$(date)] Created /mnt/unrar" >&2

# Make the mount shared so it's visible outside this process
mount --make-rshared / 2>/dev/null || true

echo "[$(date)] Starting roar FUSE filesystem..." >&2
echo "[$(date)] Command: /opt/roar /mnt/ftp /mnt/unrar" >&2

# Enable debug logging
export ROAR_LOG_LEVEL=debug

# Run roar in foreground but also log if it exits
/opt/roar /mnt/ftp /mnt/unrar &
ROAR_PID=$!
echo "[$(date)] Roar started with PID: $ROAR_PID" >&2

# Wait a moment for mount to initialize
sleep 3

# Check if roar is still running
if ! kill -0 $ROAR_PID 2>/dev/null; then
    echo "[$(date)] ERROR: roar exited immediately!" >&2
    exit 1
fi

# Check if mount succeeded
if ! mountpoint -q /mnt/unrar; then
    echo "[$(date)] ERROR: /mnt/unrar is not a mountpoint!" >&2
    kill $ROAR_PID 2>/dev/null || true
    exit 1
fi

echo "[$(date)] Mount successful, roar is running" >&2
echo "[$(date)] Contents of /mnt/unrar:" >&2
ls -la /mnt/unrar >&2

# Wait for roar process
wait $ROAR_PID
EXIT_CODE=$?
echo "[$(date)] Roar exited with code: $EXIT_CODE" >&2
exit $EXIT_CODE

