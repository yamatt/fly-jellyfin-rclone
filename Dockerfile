FROM federicoponzi/horust:v0.1.7 as horust

FROM jellyfin/jellyfin:10.9.7

COPY --from=horust /sbin/horust /horust
COPY ./services /services

ENTRYPOINT ["/horust", "--services-path", "/services"]
