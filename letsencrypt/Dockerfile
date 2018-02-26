# MIT License
# Copyright (c) 2018 Nicola Worthington <nicolaw@tfb.net>

FROM certbot/certbot:latest
ADD init-and-run /usr/local/bin/init-and-run
RUN chmod a+x /usr/local/bin/*
ADD root.crontab /var/spool/cron/crontabs/root
ENTRYPOINT []
CMD /usr/local/bin/init-and-run
