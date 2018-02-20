# MIT License
# Copyright (c) 2018 Nicola Worthington <nicolaw@tfb.net>

FROM alpine:latest
RUN apk update && apk add git
ADD init-and-run /usr/local/bin/init-and-run
ADD git-sync.sh /usr/local/bin/git-sync.sh
ADD static-website.sh /usr/local/bin/static-website.sh
RUN chmod a+x /usr/local/bin/*
ADD root.crontab /var/spool/cron/crontabs/root
CMD /usr/local/bin/init-and-run
