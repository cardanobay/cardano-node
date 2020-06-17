#####################################################
##      The Lightweight & Secure Cardano Node      ##
#####################################################

# ----------------------------------------------------------------
# CARDANO-NODE - BUILDING STAGE
# ----------------------------------------------------------------

# !!! COMPILE THIS ONLY ON AARCH64 !!!

# LOAD DEBIAN IMAGE
FROM arm64v8/ubuntu:18.04 AS builder

# SET DYNAMIC VARIABLES
# > To override them, use the "--build-arg" argument
#   Example : buildah bud ... --build-arg USER_ID="1000"
ARG NODE_VERSION="1.13.0-rewards"
ARG USER_NAME="cardano-node"
ARG USER_ID="256"
ARG GROUP_NAME="cardano-node"
ARG GROUP_ID="256"
ARG CABAL_VERSION="3.2.0.0"
ARG GHC_VERSION="8.6.5"
ARG OS_ARCH="aarch64"

# INSTALL PREREQUISITES
RUN apt update -y \
  && apt-get -y install build-essential pkg-config libffi-dev libgmp-dev libssl-dev libtinfo-dev libsystemd-dev \
     zlib1g-dev make g++ tmux git jq wget libncursesw5 xz-utils llvm

# ADD CARDANO NODE USER AND GROUP + ROOT USER AND GROUP
WORKDIR /build/rootfs/etc
RUN cp --parents -f /usr/sbin/nologin ../ \
 && echo "root:x:0:0:root:/denied:/usr/sbin/nologin" > passwd \
 && echo "${USER_NAME}:x:${USER_ID}:${GROUP_ID}:Cardano Node Service Account:/denied:/usr/sbin/nologin" >> passwd \
 && echo "root:x:0:" > group \
 && echo "${GROUP_NAME}:x:${GROUP_ID}:" >> group

# ADD A MINIMALIST SERVICES FILES (REQUIRED BY THE CARDANO NODE BINARY)
RUN touch services \
 && echo "ntp             123/tcp" >> services \
 && echo "ntp             123/udp" >> services \
 && echo "domain          53/tcp"  >> services \
 && echo "domain          53/udp"  >> services

# ADD LOCAL DNS RESOLUTION CAPABILITIES
RUN echo "hosts: files dns" > nsswitch.conf

# ADD DNS RESOLUTION CAPABILITIES
WORKDIR /build/rootfs
RUN cp --parents -f /lib/${OS_ARCH}-linux-gnu/libnss_dns.so.2 . \
 && cp --parents -f /lib/${OS_ARCH}-linux-gnu/libnss_files.so.2 .

# INSTALL GHC
# The Glasgow Haskell Compiler
WORKDIR /build/ghc
RUN wget -qO-  https://downloads.haskell.org/ghc/${GHC_VERSION}/ghc-${GHC_VERSION}-${OS_ARCH}-ubuntu18.04-linux.tar.xz | tar xJf - -C . --strip-components 1 \
 && ./configure \
 && make install

# INSTALL CABAL
# The Haskell Common Architecture for Building Applications and Libraries
WORKDIR /build/cabal
RUN wget -qO- https://github.com/haskell/cabal/archive/Cabal-v${CABAL_VERSION}.tar.gz | tar xzfv - -C . --strip-components 1 \
  && cd cabal-install \
  && ./bootstrap.sh \
  && cp ./dist/build/cabal/cabal /usr/local/bin

# DOWNLOAD AND PREPARE CARDANO SOURCE CODE
WORKDIR /build/cardano
RUN git clone https://github.com/input-output-hk/cardano-node.git . \
 && git fetch --all --tags \
 && tag=$([ "${NODE_VERSION}" = "latest" ] && echo $(git describe --tags $(git rev-list --tags --max-count=1)) || echo ${NODE_VERSION}) \
 && git checkout tags/${tag} \
 && cabal update

# BUILD CARDANO-NODE AND CARDANO-CLI
RUN cabal build all
WORKDIR /build/rootfs
RUN mkdir -p ./usr/local/bin \
 && set -- \
              $(find /build/cardano -type f -name "cardano-node") $(find /build/cardano -type f -name "cardano-cli") \
           \
 && while [ $# -gt 0 ]; \
      do \
        ldd ${1} | grep -Po '(?<=)\/.+[^ ]+(?= )' | \
          while read -r line; \
            do \
              cp --parents -f $line . ; \
            done; \
        cp -f ${1} ./usr/local/bin \
        && shift; \
      done

# [OPTIONAL] ADD OPTIONAL UTILITIES
# > Uncomment this section to add some debugging utilities
# !!! DON'T ADD THESES UTILITIES IN PRODUCTION !!!
WORKDIR /build/rootfs
RUN set -- \
              /bin/bash /bin/ls /bin/cat /bin/echo /bin/ip /bin/ping \
              /bin/grep /usr/bin/id /usr/bin/tail /usr/bin/du \
              /usr/bin/find /usr/bin/whoami \
           \
 && while [ $# -gt 0 ]; \
      do \
        ldd ${1} | grep -Po '(?<=)\/.+[^ ]+(?= )' | \
          while read -r line; \
            do \
              cp --parents -f $line . ; \
            done; \
        cp --parents -f ${1} . \
        && shift; \
      done \
  && cp --parents -f /etc/bash.bashrc . \
  && ln -s /bin/bash ./bin/sh . \
  && cp -R --parents -f /lib/terminfo/x/ .
# ----------------------------------------------------------------
# CARDANO-NODE - FINAL CONTAINER
# ----------------------------------------------------------------

# LOAD SCRATCH IMAGE
# The smallest available image ever
FROM scratch as final

# SOME ADVERTISING ^_^
LABEL "com.cardanobay.www"="[CAB] Cardanobay.com Stake Pool"
LABEL description="The Lightweight & Secure Cardano Node"
LABEL maintainer="pascha+cardanobay@protonmail.ch"

# SET EXPOSED PORT
ARG PORT="3001"

# POPULATE ROOTFS
COPY --from=builder /build/rootfs/ /

# RUN AS UNPRIVILEGED USER BY DEFAULT
USER ${USER_NAME}
EXPOSE ${PORT}/tcp

# FORCE CARDANO NODE COMMAND
ENTRYPOINT ["cardano-node"]
CMD ["run"]
