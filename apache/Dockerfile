# MIT License
# Copyright (c) 2018 Nicola Worthington <nicolaw@tfb.net>

FROM httpd:2.4-alpine

COPY httpd.conf /usr/local/apache2/conf/httpd.conf
COPY tiddlywiki.conf /usr/local/apache2/conf/tiddlywiki.conf
COPY init-and-run /usr/local/bin/init-and-run
RUN chmod a+x /usr/local/bin/*

RUN rm -Rf /usr/local/apache2/htdocs/*

EXPOSE 80
EXPOSE 443
EXPOSE 444

CMD ["/bin/sh","/usr/local/bin/init-and-run"]
