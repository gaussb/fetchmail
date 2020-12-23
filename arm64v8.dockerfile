FROM alpine AS builder

# Download QEMU, see https://github.com/docker/hub-feedback/issues/1261
ENV QEMU_URL https://github.com/balena-io/qemu/releases/download/v3.0.0%2Bresin/qemu-3.0.0+resin-aarch64.tar.gz
RUN apk add curl && curl -L ${QEMU_URL} | tar zxvf - -C . --strip-components 1

FROM arm64v8/alpine:latest
MAINTAINER gauss.b@ub-gauss.de

# Add QEMU
COPY --from=builder qemu-aarch64-static /usr/bin

#install necessary packages
RUN apk update; \
    apk upgrade; \
    apk add fetchmail openssl logrotate;

#set workdir
WORKDIR /data

#setup fetchmail stuff, fetchmail user is created by installing the fetchmail package
RUN chown fetchmail:fetchmail /data; \
    chmod 0744 /data;

#add logrotate fetchmail config
ADD etc/logrotate.d/fetchmail /etc/logrotate.d/fetchmail
#add startup script
ADD start.sh /bin/start.sh
#add fetchmail_daemon script
ADD fetchmail_daemon.sh /bin/fetchmail_daemon.sh

#set startup script rights
RUN chmod 0700 /bin/start.sh; \
    chown fetchmail:fetchmail /bin/fetchmail_daemon.sh

VOLUME ["/data"]
CMD ["/bin/sh", "/bin/start.sh"]
