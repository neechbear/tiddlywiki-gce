# MIT License
# Copyright (c) 2018 Nicola Worthington <nicolaw@tfb.net>

FROM node:9.5.0-alpine
RUN npm install -g tiddlywiki
RUN apk update && apk add git openssh-client
ADD init-and-run /usr/local/bin/init-and-run
ADD git-sync.sh /usr/local/bin/git-sync.sh
ADD static-website.sh /usr/local/bin/static-website.sh
RUN chmod a+x /usr/local/bin/*
ADD root.crontab /var/spool/cron/crontabs/root
RUN mkdir -p /var/lib/tiddlywiki
WORKDIR /var/lib/tiddlywiki
CMD /usr/local/bin/init-and-run
