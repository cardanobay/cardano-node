#####################################################
##      The Lightweight & Secure Cardano Node      ##
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

# INSTALL PREREQUISITES
RUN apt update -y \
  && apt install -y netbase wget xz-utils

# ADD CARDANO NODE USER AND GROUP + ROOT USER AND GROUP
WORKDIR /build/rootfs/etc
RUN cp --parents -f /usr/sbin/nologin ../ \
 && echo "root:x:0:0:root:/denied:/usr/sbin/nologin" > passwd \
 && echo "${USER_NAME}:x:${USER_ID}:${GROUP_ID}:Cardano Node Service Account:/denied:/usr/sbin/nologin" >> passwd \
 && echo "root:x:0:" > group \
 && echo "${GROUP_NAME}:x:${GROUP_ID}:" >> group

# ADD THE SERVICES LIST FILES, REQUIRED BY THE CARDANO NODE BINARY
RUN cp -f /etc/services .

# ADD THE CARDANO NODE BINARY
WORKDIR /build/rootfs/usr/local/bin
RUN wget https://github.com/cardanobay/cardano-node/releases/download/${NODE_VERSION}/cardano-node.tar.xz \
    && wget https://github.com/cardanobay/cardano-node/releases/download/${NODE_VERSION}/sha256sum \
    && echo "$(cat sha256sum)" | sha256sum --check \
    && tar -xf cardano-node.tar.xz \
    && rm cardano-node.tar.xz sha256sum

# ADD DNS RESOLUTION CAPABILITIES
WORKDIR /build/rootfs
RUN cp --parents -f /lib/x86_64-linux-gnu/libnss_dns.so.2 . \
 && cp --parents -f /lib/x86_64-linux-gnu/libnss_files.so.2 .

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
