# MIT License
# Copyright (c) 2018 Nicola Worthington <nicolaw@tfb.net>

FROM node:9.5.0-alpine

RUN npm install -g tiddlywiki
RUN apk update && apk add git openssh-client

COPY init-and-run /usr/local/bin/init-and-run
COPY git-sync.sh /usr/local/bin/git-sync.sh
COPY static-website.sh /usr/local/bin/static-website.sh
RUN chmod a+x /usr/local/bin/*

COPY root.crontab /var/spool/cron/crontabs/root

# TODO: Mount this as a volume from the host instead.
COPY id_rsa /root/.ssh/id_rsa

RUN mkdir -p /var/lib/tiddlywiki
WORKDIR /var/lib/tiddlywiki

CMD ["/bin/sh","/usr/local/bin/init-and-run"]
