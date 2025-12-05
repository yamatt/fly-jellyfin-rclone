#!/bin/bash
set -euo pipefail

mkdir -p /mnt/unrar

/opt/roar --allow-other /mnt/ftp /mnt/unrar
