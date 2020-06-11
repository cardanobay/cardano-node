#####################################################
## The Lightweight & Secure Cardano Node Container ##
#####################################################

# ----------------------------------------------------------------
# CARDANO-NODE - BUILDING STAGE
# ----------------------------------------------------------------

# LOAD DEBIAN IMAGE
FROM debian AS builder

# SET DYNAMIC VARIABLES
# > To override them, use the "--build-arg" argument
#   Example : buildah bud ... --build-arg USER_ID="1000"
ARG NODE_VERSION="1.13.0"
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
RUN cp --parents -f /usr/sbin/nologin ../ \
 && echo "root:x:0:0:root:/denied:/usr/sbin/nologin" > passwd \
 && echo "${USER_NAME}:x:${USER_ID}:${GROUP_ID}:Cardano Node Service Account:/denied:/usr/sbin/nologin" >> passwd \
 && echo "root:x:0:" > group \
 && echo "${GROUP_NAME}:x:${GROUP_ID}:" >> group

# ADD DNS RESOLUTION CAPABILITIES
WORKDIR /build/rootfs
RUN cp --parents -f /lib/x86_64-linux-gnu/libnss_dns.so.2 . \
 && cp --parents -f /lib/x86_64-linux-gnu/libnss_files.so.2 .

# [OPTIONAL] ADD OPTIONAL UTILITIES
# > Uncomment this section to add some debugging utilities
# !!! DON'T ADD THESES UTILITIES IN PRODUCTION !!!
#RUN set -- \
#              /bin/bash /bin/ls /bin/cat /bin/echo /bin/ip /bin/ping \
#              /bin/grep /usr/bin/id /usr/bin/tail /usr/bin/du \
#              /usr/bin/find /usr/bin/whoami \
#           \
# && while [ $# -gt 0 ]; \
#      do \
#        ldd ${1} | grep -Po '(?<=)\/.+[^ ]+(?= )' | \
#          while read -r line; \
#            do \
#              cp --parents -f $line . ; \
#            done; \
#        cp --parents -f ${1} . \
#        && shift; \
#      done

# ----------------------------------------------------------------
# CARDANO-NODE - FINAL CONTAINER
# ----------------------------------------------------------------

# LOAD SCRATCH IMAGE
# The smallest available image ever
FROM scratch as final

# SOME ADVERTISING ^_^
LABEL "com.cardanobay.www"="[CAB] Cardanobay.com Stake Pool"
LABEL description="The Lightweight & Secure Cardano Node Container"
LABEL maintainer="pascha+cardanobay@protonmail.ch"

# SET EXPOSED PORT
ARG PORT="3001"

# POPULATE ROOTFS
COPY --from=builder /build/rootfs/ /

# RUN AS CARDANO NODE USER BY DEFAULT
USER ${USER_NAME}
EXPOSE ${PORT}/tcp

# FORCE CARDANO NODE COMMAND 
ENTRYPOINT ["cardano-node"]
CMD ["run"]
