FROM federicoponzi/horust:v0.1.7 as horust
FROM bitnami/rclone:1.67.0-debian-12-r3 as rclone

FROM ubuntu:noble-20240605 as rar2fs

# https://ftp.osuosl.org/pub/blfs/conglomeration/unrarsrc/
ARG UNRAR_VERSION=7.0.9
# https://github.com/hasse69/rar2fs/releases
ARG RAR2FS_VERSION=1.29.7

RUN apt-get update && apt-get install --no-install-recommends --no-install-suggests --yes  wget make libfuse-dev g++ && \
    wget http://www.rarlab.com/rar/unrarsrc-$UNRAR_VERSION.tar.gz && \
    tar zxvf unrarsrc-$UNRAR_VERSION.tar.gz && \
    cd unrar && \
    make && sudo make install  && \
    make lib && sudo make install-lib  && \
    cd ..  && \
    wget https://github.com/hasse69/rar2fs/releases/download/v$RAR2FS_VERSION/rar2fs-$RAR2FS_VERSION.tar.gz  && \
    tar zxvf rar2fs-$RAR2FS_VERSION.tar.gz  && \
    cd rar2fs-$RAR2FS_VERSION  && \
    ./configure --with-unrar=../unrar --with-unrar-lib=/usr/lib/  && \
    make && sudo make install  && \
    apt-get clean autoclean --yes && \
    apt-get autoremove --yes && \
    rm -rf /var/cache/apt/archives* /var/lib/apt/lists/* 

FROM jellyfin/jellyfin:10.9.7

COPY --from=rclone /opt/bitnami/rclone/bin/rclone /rclone
COPY --from=rar2fs /usr/bin/rar2fs /rar2fs

COPY --from=horust /sbin/horust /horust
COPY ./services /services

RUN apt-get update --yes && \
    apt-get install --no-install-recommends --no-install-suggests --yes fuse3=3.14.0-4 && \
    apt-get clean autoclean --yes && \
    apt-get autoremove --yes && \
    rm -rf /var/cache/apt/archives* /var/lib/apt/lists/*

ENTRYPOINT ["/horust", "--services-path", "/services"]
