# MIT License
# Copyright (c) 2018 Nicola Worthington <nicolaw@tfb.net>

FROM node:9.5.0-alpine
RUN npm install -g tiddlywiki
VOLUME /var/lib/tiddlywiki
WORKDIR /var/lib/tiddlywiki
EXPOSE 8080
ADD syncer.patch /usr/local/src/syncer.patch
ADD init-and-run /usr/local/bin/init-and-run
RUN chmod a+x /usr/local/bin/*
CMD /usr/local/bin/init-and-run
