FROM alpine:3.12
LABEL maintainer "Greg Froese <greg.froese@gmail.com>"

RUN apk add --update tzdata bash mysql-client gzip openssl mariadb-connector-c && rm -rf /var/cache/apk/*

ARG OS=linux
ARG ARCH=armel
ARG DOCKERIZE_VERSION=v0.6.1

RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-$OS-$ARCH-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-$OS-$ARCH-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-$OS-$ARCH-$DOCKERIZE_VERSION.tar.gz

ENV CRON_TIME="0 3 * * sun" \
    MYSQL_HOST="mysql" \
    MYSQL_PORT="3306" \
    TIMEOUT="10s"

COPY ["run.sh", "backup.sh", "restore.sh", "/"]
RUN mkdir /backup && chmod u+x /backup.sh /restore.sh
VOLUME ["/backup"]

CMD dockerize -wait tcp://${MYSQL_HOST}:${MYSQL_PORT} -timeout ${TIMEOUT} /run.sh
