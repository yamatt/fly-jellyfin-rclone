FROM federicoponzi/horust:v0.1.7 as horust
FROM bitnami/rclone:1.69.0-debian-12-r3 as rclone

FROM jellyfin/jellyfin:10.10.6

COPY --from=rclone /opt/bitnami/rclone/bin/rclone /rclone

COPY --from=horust /sbin/horust /horust
COPY ./services /services

RUN apt-get update --yes && \
    apt-get install --no-install-recommends --no-install-suggests --yes fuse3=3.14.0-4 && \
    apt-get clean autoclean --yes && \
    apt-get autoremove --yes && \
    rm -rf /var/cache/apt/archives* /var/lib/apt/lists/*

ENTRYPOINT ["/horust", "--services-path", "/services"]
