FROM federicoponzi/horust:v0.1.7 as horust
FROM bitnami/rclone:1.67.0-debian-12-r3 as rclone

FROM jellyfin/jellyfin:10.9.7

COPY --from=rclone /opt/bitnami/rclone/bin/rclone /rclone

COPY --from=horust /sbin/horust /horust
COPY ./services /services

ENTRYPOINT ["/horust", "--services-path", "/services"]
