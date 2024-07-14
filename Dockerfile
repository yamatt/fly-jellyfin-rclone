FROM rust:1.79.0-alpine3.20 as horust

RUN apk add --no-cache git=2.39.2 && \
    git clone https://github.com/FedericoPonzi/Horust.git -o /horust-src
WORKDIR /horust-src
RUN git checkout v0.1.7 && \
    cargo build --release

FROM jellyfin/jellyfin:10.9.7

COPY --from=horust /horust-src/horust /horust
COPY ./services /services

ENTRYPOINT ["/horust"]
