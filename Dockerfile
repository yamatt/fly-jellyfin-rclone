FROM federicoponzi/horust:0.1.10 as horust
FROM rclone/rclone:1.73.0 as rclone
FROM ghcr.io/yamatt/roar:1.0.0 as roar

FROM jellyfin/jellyfin:10.11.6

COPY --from=rclone /usr/local/bin/rclone /opt/rclone
COPY --from=roar /usr/local/bin/roar /opt/roar

COPY --from=horust /sbin/horust /opt/horust
COPY ./src/services /etc/horust/services

COPY src/pkglist /tmp/pkglist

RUN apt-get update --yes && \
    apt-get install --no-install-recommends --no-install-suggests --yes $(cat /tmp/pkglist) && \
    apt-get clean autoclean --yes && \
    apt-get autoremove --yes && \
    rm -rf /var/cache/apt/archives* /var/lib/apt/lists/*

COPY ./src/scripts /opt/scripts

ENTRYPOINT ["/opt/horust", "--services-path", "/etc/horust/services"]
