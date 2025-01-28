FROM federicoponzi/horust:v0.1.7 as horust
FROM bitnami/rclone:1.69.0-debian-12-r2 as rclone

FROM debian:bookworm as rar2fs

ARG HOME=/root
# https://ftp.osuosl.org/pub/blfs/conglomeration/unrarsrc/
ARG UNRAR_VERSION=7.1.3
# https://github.com/hasse69/rar2fs/releases
ARG RAR2FS_VERSION=1.29.7

WORKDIR $HOME

RUN apt-get update && apt-get install --no-install-recommends --no-install-suggests --yes  wget=1.21.3-1+b2 make=4.3-4.1 libfuse-dev=2.9.9-6+b1 g++=4:12.2.0-3 ca-certificates=20230311 && \
    apt-get clean autoclean --yes && \
    apt-get autoremove --yes && \
    rm -rf /var/cache/apt/archives* /var/lib/apt/lists/*

RUN wget --progress=dot:giga https://www.rarlab.com/rar/unrarsrc-$UNRAR_VERSION.tar.gz --output-document=unrarsrc.tar.gz && \
    tar zxvf unrarsrc.tar.gz

WORKDIR $HOME/unrar

RUN make lib

WORKDIR $HOME

RUN wget --progress=dot:giga https://github.com/hasse69/rar2fs/releases/download/v$RAR2FS_VERSION/rar2fs-$RAR2FS_VERSION.tar.gz  --output-document=rar2fs.tar.gz && \
    tar zxvf rar2fs.tar.gz

WORKDIR $HOME/rar2fs-$RAR2FS_VERSION

RUN ./configure --with-unrar=$HOME/unrar --with-unrar-lib=/usr/lib/ && make && \
    cp src/rar2fs /rar2fs

FROM jellyfin/jellyfin:10.10.5

COPY --from=rclone /opt/bitnami/rclone/bin/rclone /rclone
COPY --from=rar2fs /rar2fs /rar2fs

COPY --from=horust /sbin/horust /horust
COPY ./services /services

RUN apt-get update --yes && \
    apt-get install --no-install-recommends --no-install-suggests --yes fuse3=3.14.0-4 libfuse2=2.9.9-6+b1 && \
    apt-get clean autoclean --yes && \
    apt-get autoremove --yes && \
    rm -rf /var/cache/apt/archives* /var/lib/apt/lists/*

ENTRYPOINT ["/horust", "--services-path", "/services"]
