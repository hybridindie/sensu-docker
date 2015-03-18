FROM ubuntu:trusty
MAINTAINER John Dilts <john.dilts@enstratius.com>

RUN apt-get update && apt-get upgrade -y && apt-get install -y wget git-core \
                      supervisor graphite-carbon graphite-web apache2 \
                      apache2-mpm-worker libapache2-mod-wsgi

RUN graphite-manage syncdb --noinput
RUN chown _graphite /var/lib/graphite -R

ADD certs /tmp/ssl_certs
ADD graphite-run.sh /tmp/

RUN rm -f /etc/apache2/sites-enabled/000-default.conf
RUN cp /usr/share/graphite-web/apache2-graphite.conf /etc/apache2/sites-enabled/graphite.conf

ADD supervisor.conf /etc/supervisor/conf.d/supervisord.conf
EXPOSE 80
EXPOSE 2003
EXPOSE 8080


CMD ["/tmp/graphite-run.sh"]
