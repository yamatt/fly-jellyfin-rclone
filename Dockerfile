FROM rust:1.79.0-alpine3.20 as horust

WORKDIR /
RUN apk add --no-cache git=2.45.2-r0 musl-dev=1.2.5-r0 && \
    git clone https://github.com/FedericoPonzi/Horust.git horust-src
WORKDIR /horust-src
RUN git checkout v0.1.7 && \
    cargo build --release && \
    ls -lah .

FROM jellyfin/jellyfin:10.9.7

COPY --from=horust /horust-src/horust /horust
COPY ./services /services

ENTRYPOINT ["/horust"]
