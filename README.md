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
