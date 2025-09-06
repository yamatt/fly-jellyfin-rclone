#!/bin/bash
set -euo pipefail

mkdir -p /mnt/unrar

/opt/rar2fs -f /mnt/ftp /mnt/unrar -o allow_other --seek-length=1
