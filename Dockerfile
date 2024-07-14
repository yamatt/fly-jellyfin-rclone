FROM rust:1.79.0-slim-bullseye as horust

RUN apt-get update --yes && \
    apt-get install --yes --no-install-recommends git=2.39.2-1.1&& \
    git clone https://github.com/FedericoPonzi/Horust.git -o /horust-src
WORKDIR /horust-src
RUN git checkout v0.1.7 && \
    cargo build --release && \
    apt-get clean autoclean --yes && \
    apt-get autoremove --yes && \
    rm -rf /var/cache/apt/archives* /var/lib/apt/lists/*

FROM jellyfin/jellyfin:10.9.7

COPY --from=horust /horust-src/horust /horust
COPY ./services /services

ENTRYPOINT ["/horust"]
