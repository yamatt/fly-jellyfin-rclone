FROM federicoponzi/horust:0.1.10 as horust
FROM rclone/rclone:1.72.0 as rclone

FROM jellyfin/jellyfin:10.11.3

COPY --from=rclone /usr/local/bin/rclone /opt/rclone
COPY ./files/rar2fs /opt/rar2fs

COPY --from=horust /sbin/horust /opt/horust
COPY ./src/services /etc/horust/services

RUN apt-get update --yes && \
    apt-get install --no-install-recommends --no-install-suggests --yes fuse3=3.14.0-4 libfuse2=2.9.9-6+b1 && \
    apt-get clean autoclean --yes && \
    apt-get autoremove --yes && \
    rm -rf /var/cache/apt/archives* /var/lib/apt/lists/*

COPY ./src/scripts /opt/scripts

ENTRYPOINT ["/opt/horust", "--services-path", "/etc/horust/services"]
