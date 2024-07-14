FROM rust:1.79.0-slim-bullseye as horust

RUN apt update && \
    apt install git && \
    git clone https://github.com/FedericoPonzi/Horust.git -o horust && \
    cd horust && \
    git checkout v0.1.7 && \
    cargo build --release

FROM jellyfin/jellyfin:10.9.7

COPY --from=horust horust/horust /horust
COPY service /services

ENTRYPOINT ["/horust"]
