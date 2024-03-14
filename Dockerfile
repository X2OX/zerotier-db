FROM debian:bookworm-slim as builder

ENV VERSION=v1.12.2

WORKDIR /app

RUN apt-get update -y && apt-get install -y add --no-cache git python3 npm make linux-headers curl pkgconfig openssl-dev jq build-base clang

RUN set -x\
    && curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y\
    && source "$HOME/.cargo/env"\
    && git clone --quiet --depth 1 -b $VERSION https://github.com/zerotier/ZeroTierOne.git\
    && cd ZeroTierOne && make ZT_SYMLINK=1 && make && make install

#make ztncui 
RUN set -x \
    && mkdir /app -p \
    && cd /app \
    && git clone --progress https://github.com/key-networks/ztncui.git\
    && cd /app/ztncui/src \
    && npm install -g node-gyp\
    && npm install 

FROM debian:bookworm-slim

WORKDIR /app


ENV IP_ADDR4=''
ENV IP_ADDR6=''

ENV ZT_PORT=9994
ENV API_PORT=3443
ENV FILE_SERVER_PORT=3000

ENV FILE_KEY=''

COPY --from=builder /app/ztncui /bak/ztncui
COPY --from=builder /var/lib/zerotier-one /bak/zerotier-one
COPY --from=builder /app/ZeroTierOne/zerotier-one /usr/sbin/zerotier-one

ADD https://github.com/kaaass/ZeroTierOne/releases/download/mkmoonworld-1.0/mkmoonworld-x86_64 /app/mkmoonworld-x86_64

VOLUME [ "/app/dist","/app/ztncui","/var/lib/zerotier-one","/app/config"]

CMD ["/bin/sh","--"]