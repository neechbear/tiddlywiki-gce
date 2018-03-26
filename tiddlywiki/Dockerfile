# MIT License
# Copyright (c) 2018 Nicola Worthington <nicolaw@tfb.net>

FROM node:9.5.0-alpine

RUN npm install -g tiddlywiki

ADD syncer.patch /usr/local/src/syncer.patch
ADD init-and-run /usr/local/bin/init-and-run
RUN chmod a+x /usr/local/bin/*

EXPOSE 8080
WORKDIR /var/lib/tiddlywiki

CMD ["/bin/sh","/usr/local/bin/init-and-run"]
