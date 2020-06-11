#####################################################
## The Lightweight & Secure Cardano Node Container ##
#####################################################

# LOAD DEBIAN IMAGE
# > Use debian for the building stage ONLY
FROM debian AS builder

# SET DYNAMIC VARIABLES
# > To override them, inject with docker/podman/buildah "--build-arg" argument
#   Example : buildah bud ... --build-arg NODE_VERSION="1.12.0"
ARG NODE_VERSION="latest"
ARG USER_NAME="cardano-node"
ARG USER_ID="256"
ARG GROUP_NAME="cardano-node"
ARG GROUP_ID="256"
ARG GHC_VERSION="8.6.5"
ARG CABAL_VERSION="3.2.0.0"
ARG OS_ARCH="x86_64"
ARG HASKELL_REPO="https://downloads.haskell.org"

# INSTALL PREREQUISITES
RUN apt update -y \
 && apt install -y \
    build-essential pkg-config libffi-dev libgmp-dev libssl-dev libtinfo-dev \
    libsystemd-dev zlib1g-dev make g++ git wget libncursesw5

# INSTALL CABAL
# The Haskell Common Architecture for Building Applications and Libraries
WORKDIR /build/cabal
RUN wget -qO- ${HASKELL_REPO}/~cabal/cabal-install-${CABAL_VERSION}/cabal-install-${CABAL_VERSION}-${OS_ARCH}-unknown-linux.tar.xz | tar xJf - -C .

# INSTALL GHC
# The Glasgow Haskell Compiler
WORKDIR /build/ghc
RUN wget -qO- ${HASKELL_REPO}/~ghc/${GHC_VERSION}/ghc-${GHC_VERSION}-${OS_ARCH}-deb9-linux.tar.xz | tar xJf - -C . --strip-components 1 \
  && ./configure \
  && make -j $(nproc) install

# GET CARDANO NODE SOURCE CODE
WORKDIR /build/cardano-node
RUN git clone https://github.com/input-output-hk/cardano-node.git . \
 && git fetch --all --tags \
 && tag=$([ "$NODE_VERSION" = "latest" ] \
        && echo $(git describe --tags $(git rev-list --tags --max-count=1)) \
        || echo ${NODE_VERSION}) \
 && git checkout tags/${tag}

# BUILD CARDANO NODE BINARY FROM SOURCES
RUN /build/cabal/cabal update \
 && /build/cabal/cabal install --disable-executable-dynamic --enable-executable-static -j$(nproc) cardano-node


# COPY CARDANO NODE BINARY AND REQUIRED LIBRARIES
WORKDIR /build/rootfs
RUN mkdir -p ./usr/local/bin \
 && cp /root/.cabal/bin/cardano-node ./usr/local/bin \
 && ldd ./usr/local/bin/cardano-node | grep -Po '(?<=)\/.+[^ ]+(?= )' | while read -r line; do cp --parents -f $line . ; done

# ADD CARDANO NODE USER AND GROUP + ROOT USER AND GROUP
WORKDIR /build/rootfs/etc
RUN cp --parents -fP /usr/sbin/nologin ../ \
 && echo "root:x:0:0:root:/denied:/usr/sbin/nologin" > passwd \
 && echo "${USER_NAME}:x:${USER_ID}:${GROUP_ID}:Cardano Node Service Account:/denied:/usr/sbin/nologin" >> passwd \
 && echo "root:x:0:" > group \
 && echo "${GROUP_NAME}:x:${GROUP_ID}:" >> group

# LOAD SCRATCH IMAGE
# The smallest available image ever
FROM scratch as final

# SOME ADVERTISING ^_^
LABEL "com.cardanobay.www"="[CAB] Cardanobay.com Stake Pool"
LABEL description="The Lightweight & Secure Cardano Node Container"
LABEL maintainer="pascha+cardanobay@protonmail.ch"

# SET DYNAMIC VARIABLES
# > To override them, inject with docker/podman/buildah "--build-arg" argument
#   Example : buildah bud ... --build-arg PORT="1234"
ARG PORT="3001"

# POPULATE ROOTFS
COPY --from=builder /build/rootfs/ /

# [OPTIONAL] ADD OPTIONAL UTILITIES
# > Uncomment this section to add some debugging utilities
# !!! DON'T ADD THESES UTILITIES IN PRODUCTION !!!

#ARG LIB="/lib/x86_64-linux-gnu"
#ARG LIB64="/lib64"
#COPY --from=builder ${LIB}/libselinux.so.1 ${LIB}/
#COPY --from=builder ${LIB}/libm.so.6 ${LIB}/
#COPY --from=builder ${LIB}/libc.so.6 ${LIB}/
#COPY --from=builder ${LIB}/libpcre.so.3 ${LIB}/
#COPY --from=builder ${LIB}/libdl.so.2 ${LIB}/
#COPY --from=builder ${LIB}/libpthread.so.0 ${LIB}/
#COPY --from=builder ${LIB64}/ld-linux-x86-64.so.2 ${LIB64}/
#COPY --from=builder /bin/dash /bin/sh
#COPY --from=builder /bin/ls /bin/
#COPY --from=builder /bin/cat /bin/
#COPY --from=builder /bin/echo /bin/
#COPY --from=builder /usr/bin/whoami /bin/
#COPY --from=builder /usr/bin/id /bin/
#COPY --from=builder /usr/bin/tail /bin/
#COPY --from=builder /usr/bin/du /bin/
#COPY --from=builder /bin/grep /bin/
#COPY --from=builder /usr/bin/find /bin/

# RUN AS CARDANO NODE USER BY DEFAULT
USER ${USER_NAME}
EXPOSE ${PORT}/tcp

# FORCE CARDANO NODE COMMAND 
ENTRYPOINT ["cardano-node"]
CMD ["run"]
