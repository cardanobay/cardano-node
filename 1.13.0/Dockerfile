#####################################################
## The Lightweight & Secure Cardano Node Container ##
#####################################################

# LOAD DEBIAN IMAGE
# > Use debian for the building stage ONLY
FROM debian AS builder

# SET DYNAMIC VARIABLES
# > To override them, inject with docker/podman/buildah "--build-arg" argument
#   Example : buildah bud ... --build-arg USER_NAME="new-user"
ARG NODE_VERSION="1.13.0"
ARG GHC_VERSION="8.6.5"
ARG CABAL_VERSION="3.2.0.0"
ARG OS_ARCH="x86_64"
ARG HASKELL_REPO="https://downloads.haskell.org"

# INSTALL PREREQUISITES
RUN apt update -y \
 && apt install -y \
    build-essential pkg-config libffi-dev libgmp-dev libssl-dev libtinfo-dev \
    libsystemd-dev zlib1g-dev make g++ git wget libncursesw5 xz-utils curl

# INSTALL CABAL
# The Haskell Common Architecture for Building Applications and Libraries
WORKDIR /build/cabal

RUN echo "DEBUGGING >>> ${HASKELL_REPO} ${CABAL_VERSION} ${OS_ARCH}"
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
 && git checkout tags/${NODE_VERSION}

# BUILD CARDANO NODE BINARY FROM SOURCES
RUN /build/cabal/cabal update \
 && /build/cabal/cabal install -j$(nproc) cardano-node

# LOAD SCRATCH IMAGE
# The smallest available image ever
FROM scratch as final

# SET DYNAMIC VARIABLES
# > To override them, inject with docker/podman/buildah "--build-arg" argument
#   Example : buildah bud ... --build-arg USER_NAME="new-user"
ARG USER_NAME="cardano-node"
ARG USER_ID="256"
ARG GROUP_NAME="cardano-node"
ARG GROUP_ID="256"

# SET STATIC VARIABLES
# > Currently, only x86_64 architecture is supported, change this at your own risks
ARG LIB="/lib/x86_64-linux-gnu"
ARG LIB64="/lib64"
ARG HASKELL_REPO="https://downloads.haskell.org"

# PUT SOME ADVERTISING ^_^
LABEL "com.cardanobay.www"="[CAB] Cardanobay.com Stake Pool"
LABEL description="The Lightweight & Secure Cardano Node Container"
LABEL maintainer="pascha+cardanobay@protonmail.ch"

# ADD A SHELL
# > Mandatory to run commands inside a sratch image
COPY --from=builder ${LIB}/libc.so.6 ${LIB}/
COPY --from=builder ${LIB64}/ld-linux-x86-64.so.2 ${LIB64}/
COPY --from=builder /bin/dash /bin/sh

# ADD CARDANO NODE USER AND GROUP
COPY --from=builder /usr/sbin/nologin /bin/
RUN echo "root:x:0:0:root:/denied:/bin/nologin" > /etc/passwd \
 && echo "${USER_NAME}:x:${USER_ID}:${GROUP_ID}:Cardano Node Service Account:/denied:/bin/nologin" >> /etc/passwd \
 && echo "root:x:0:" > /etc/group \
 && echo "${GROUP_NAME}:x:${GROUP_ID}:" >> /etc/group

# ADD THE CARDANO NODE REQUIRED LIBRARIES
COPY --from=builder ${LIB}/libc.so.6 ${LIB}/
COPY --from=builder ${LIB}/libm.so.6 ${LIB}/
COPY --from=builder ${LIB}/libtinfo.so.6 ${LIB}/
COPY --from=builder ${LIB}/libsystemd.so.0 ${LIB}/
COPY --from=builder ${LIB}/libz.so.1 ${LIB}/
COPY --from=builder ${LIB}/libpthread.so.0 ${LIB}/
COPY --from=builder ${LIB}/librt.so.1 ${LIB}/
COPY --from=builder ${LIB}/libutil.so.1 ${LIB}/
COPY --from=builder ${LIB}/libdl.so.2 ${LIB}/
COPY --from=builder ${LIB}/liblzma.so.5 ${LIB}/
COPY --from=builder ${LIB}/libgcrypt.so.20 ${LIB}/
COPY --from=builder ${LIB}/libgpg-error.so.0 ${LIB}/
COPY --from=builder /usr/${LIB}/libgmp.so.10 /usr/${LIB}/
COPY --from=builder /usr/${LIB}/liblz4.so.1 /usr/${LIB}/

# ADD THE CARDANO NODE COMPILED BINARY
COPY --from=builder /root/.cabal/bin/cardano-node /usr/local/bin/

# ADD OPTIONAL UTILITIES
# > You can uncomment the two following [OPTINAL] sections for debugging purposes

# [OPTIONAL] UTILITIES LIBRARIES
#COPY --from=builder ${LIB}/ld-2.28.so ${LIB}/
#COPY --from=builder ${LIB}/libselinux.so.1 ${LIB}/
#COPY --from=builder ${LIB}/libpcre.so.3 ${LIB}/
#COPY --from=builder ${LIB}/libdl.so.2 ${LIB}/
#COPY --from=builder ${LIB}/libpthread.so.0 ${LIB}/
#COPY --from=builder ${LIB}/libnss_files.so.2 ${LIB}/

# [OPTIONAL] UTILITIES BINARIES
#COPY --from=builder /bin/ls /bin/
#COPY --from=builder /bin/cat /bin/
#COPY --from=builder /usr/sbin/nologin /bin/
#COPY --from=builder /bin/echo /bin/
#COPY --from=builder /usr/bin/whoami /bin/
#COPY --from=builder /usr/bin/id /bin/
#COPY --from=builder /usr/bin/tail /bin/

# RUN AS CARDANO NODE USER BY DEFAULT
USER ${USER_NAME}

# FORCE CARDANO NODE COMMAND 
ENTRYPOINT ["cardano-node"]
CMD ["run"]
