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

You will need to [setup a rclone config file](https://rclone.org/commands/rclone_config/) with the following examples all in one file called `rclone.config`:

#### FTP

```
[ftp]
type = ftp
host = < FTP_SERVER_HOST >
user = < FTP_SERVER_USER >
port = < FTP_SERVER_PORT >
pass = < FTP_SERVER_PASS >

tls = false
explicit_tls = true
no_check_certificate = true
```

#### B2

```
[b2]
type = b2
account = < RCLONE_B2_MEDIA_KEY_ID >
key = < RCLONE_B2_MEDIA_APPLICATION_KEY >
download_url = < RCLONE_B2_MEDIA_URL >
```
