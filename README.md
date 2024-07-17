# Fly.io Jellyfin with Rclone

Run Jellyfin on Fly.io with rclone to mount remote file systems such as AWS S3, Backblaze B2 and SFTP

## Setup

### Launch

You will need to create your instance first. Do not use the default app name.

```bash
flyctl launch --name <app name>
```

### Volumes

You will need to create a data volume for Jellyfin

```bash
flyctl volumes create jellyfin_data
```

### Rclone Config

You will need to [setup some Horust configuration files](https://github.com/FedericoPonzi/Horust/blob/master/DOCUMENTATION.md) in the `services` directory to run the rclone mount instances.

Do be careful not to commit them as they likely contain secrets.

Example FTP config file. We have to use bash because we need to run two commands, one to create the mount in this example `/mnt/ftp` and then run `rclone mount` to map the remote endpoint to the mount point.

You may notice the slightly odd syntax `rclone mount :ftp:` this is because of a [not brilliantly documented feature of rclone](https://forum.rclone.org/t/syntax-for-config-less-operation/12011/4) when you want to not use a config file, and you need to specify the mount type.

```toml
command = """\
bash -c ' \
mkdir -p /mnt/ftp && \
/rclone mount :ftp: /mnt/ftp \
  --ftp-host=example.com \
  --ftp-user=anonymous \
  --ftp-pass=example-hashed-password \
  --use-mmap \
  --dir-cache-time 1000h \
  --poll-interval=15s \
  --vfs-cache-mode writes \
  --tpslimit 10 \
  --read-only \
'\
"""

[restart]
strategy = "never"
backoff = "0s"
attempts = 0
```
