FROM debian:bookworm as rar2fs

ARG HOME=/root
# https://ftp.osuosl.org/pub/blfs/conglomeration/unrarsrc/
ARG UNRAR_VERSION=6.2.12
# https://github.com/hasse69/rar2fs/releases
ARG RAR2FS_VERSION=1.29.6

WORKDIR $HOME

COPY ./rar2fs.pkglist $HOME/rar2fs.pkglist

RUN apt-get update && \
    apt-get install --no-install-recommends --no-install-suggests --yes  $(cat $HOME/rar2fs.pkglist)

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

