FROM federicoponzi/horust:v0.1.7 as horust
FROM bitnami/rclone:1.67.0-debian-12-r3 as rclone

FROM zimme/rar2fs:latest as rar2fs

FROM jellyfin/jellyfin:10.9.7

COPY --from=rclone /opt/bitnami/rclone/bin/rclone /rclone
COPY --from=rar2fs /usr/local/bin/rar2fs /rar2fs

COPY --from=horust /sbin/horust /horust
COPY ./services /services

RUN apt-get update --yes && \
    apt-get install --no-install-recommends --no-install-suggests --yes fuse3=3.14.0-4 && \
    apt-get clean autoclean --yes && \
    apt-get autoremove --yes && \
    rm -rf /var/cache/apt/archives* /var/lib/apt/lists/*

ENTRYPOINT ["/horust", "--services-path", "/services"]
