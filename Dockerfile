FROM federicoponzi/horust:0.1.10 as horust
FROM rclone/rclone:1.72.0 as rclone

FROM jellyfin/jellyfin:10.11.4

COPY --from=rclone /usr/local/bin/rclone /opt/rclone
COPY ./files/roar /opt/roar

COPY --from=horust /sbin/horust /opt/horust
COPY ./src/services /etc/horust/services

COPY src/pkglist /tmp/pkglist

RUN apt-get update --yes && \
    apt-get install --no-install-recommends --no-install-suggests --yes $(cat /tmp/pkglist) && \
    apt-get clean autoclean --yes && \
    apt-get autoremove --yes && \
    rm -rf /var/cache/apt/archives* /var/lib/apt/lists/*

COPY ./src/scripts /opt/scripts
COPY ./files/fuse.conf /etc/fuse.conf

ENTRYPOINT ["/opt/horust", "--services-path", "/etc/horust/services"]
