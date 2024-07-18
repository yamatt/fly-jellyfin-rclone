FROM federicoponzi/horust:v0.1.7 as horust
FROM bitnami/rclone:1.67.0-debian-12-r3 as rclone

FROM ubuntu:noble-20240605 as rar2fs

ARG HOME=/root
# https://ftp.osuosl.org/pub/blfs/conglomeration/unrarsrc/
ARG UNRAR_VERSION=7.0.9
# https://github.com/hasse69/rar2fs/releases
ARG RAR2FS_VERSION=1.29.7

WORKDIR $HOME

RUN apt-get update && apt-get install --no-install-recommends --no-install-suggests --yes  wget=1.21.4-1ubuntu4.1 make=4.3-4.1build2 libfuse-dev=2.9.9-8.1build1 g++=4:13.2.0-7ubuntu1 && \
    apt-get clean autoclean --yes && \
    apt-get autoremove --yes && \
    rm -rf /var/cache/apt/archives* /var/lib/apt/lists/*  && \
    wget --progress=dot:giga https://www.rarlab.com/rar/unrarsrc-$UNRAR_VERSION.tar.gz --output-document=unrarsrc.tar.gz && \
    tar zxvf unrarsrc.tar.gz
WORKDIR $HOME/unrar
RUN make && make install && \
    make lib && make install-lib
WORKDIR $HOME
RUN wget --progress=dot:giga https://github.com/hasse69/rar2fs/releases/download/v$RAR2FS_VERSION/rar2fs-$RAR2FS_VERSION.tar.gz  --output-document=rar2fs.tar.gz && \
    tar zxvf rar2fs.tar.gz
WORKDIR $HOME/rar2fs-$RAR2FS_VERSION
RUN ./configure --with-unrar=$HOME/unrar --with-unrar-lib=/usr/lib/ && make && make install

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
