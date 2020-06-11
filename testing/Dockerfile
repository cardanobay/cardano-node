FROM debian AS builder

ARG USER_NAME="cardano-node"
ARG USER_ID="256"
ARG GROUP_NAME="cardano-node"
ARG GROUP_ID="256"
ARG PORT="3001"
ARG LIB="/lib/x86_64-linux-gnu"
ARG LIB64="/lib64"

RUN apt update -y

WORKDIR /build/final/etc

RUN echo "root:x:0:0:root:/denied:/usr/sbin/nologin" > passwd \
 && echo "${USER_NAME}:x:${USER_ID}:${GROUP_ID}:Cardano Node Service Account:/denied:/usr/sbin/nologin" >> passwd \
 && echo "root:x:0:" > group \
 && echo "${GROUP_NAME}:x:${GROUP_ID}:" >> group

WORKDIR /build/final/lib/x86_64-linux-gnu
RUN cp -fP /lib/x86_64-linux-gnu/libc.so.6 . \
 && cp -fP /lib/x86_64-linux-gnu/ld-2.28.so . \
 && cp -fP /lib/x86_64-linux-gnu/libselinux.so.1 . \
 && cp -fP /lib/x86_64-linux-gnu/libpcre.so.3 . \
 && cp -fP /lib/x86_64-linux-gnu/libdl.so.2 . \
 && cp -fP /lib/x86_64-linux-gnu/libpthread.so.0 . \
 && cp -fP /lib/x86_64-linux-gnu/libnss_files.so.2 .

WORKDIR /build/final/lib64
RUN cp -fP /lib64/ld-linux-x86-64.so.2 .

WORKDIR /build/final/usr/sbin
RUN cp -fP /usr/sbin/nologin .


WORKDIR /build/final/bin
RUN cp -fP /bin/dash sh \
 && cp -fP /bin/ls .

# --------------------------------------------------------

FROM scratch as final

COPY --from=builder /build/final/ /

ENTRYPOINT ["/bin/sh"]
