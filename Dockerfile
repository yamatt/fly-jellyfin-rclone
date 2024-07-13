FROM jellyfin/jellyfin:10.9.7

RUN mkdir /data/config /data/cache

ENTRYPOINT dotnet /jellyfin/jellyfin.dll --datadir /data/config --cachedir /data/cache
