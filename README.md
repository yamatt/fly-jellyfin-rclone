# Fly.io Jellyfin with Fuse

Run Jellyfin on Fly.io with Fuse extensions to mount remote file systems such as S3, and SFTP

## Volumes

You will need to create a data volume for Jellyfin

```
fly volumes create jellyfin_data
```
