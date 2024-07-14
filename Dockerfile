FROM rust:1.79.0-slim-bullseye as horust

RUN apt-get update && \
    apt-get install git && \
    git clone https://github.com/FedericoPonzi/Horust.git -o horust
WORKDIR horust
RUN git checkout v0.1.7 && \
    cargo build --release && \
    apt-get clean autoclean --yes && \
    apt-get autoremove --yes && \
    rm -rf /var/cache/apt/archives* /var/lib/apt/lists/*

FROM jellyfin/jellyfin:10.9.7

COPY --from=horust horust/horust /horust
COPY service /services

ENTRYPOINT ["/horust"]
