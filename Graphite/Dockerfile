FROM ubuntu:trusty
MAINTAINER John Dilts <john.dilts@enstratius.com>

RUN apt-get update && apt-get upgrade -y && apt-get install -y wget git-core supervisor graphite-carbon
RUN chown _graphite /var/lib/graphite -R

ADD certs /tmp/ssl_certs
ADD graphite-run.sh /tmp/

ADD supervisor.conf /etc/supervisor/conf.d/supervisord.conf
EXPOSE 2003

CMD ["/tmp/graphite-run.sh"]
