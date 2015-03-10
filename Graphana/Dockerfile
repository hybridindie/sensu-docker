FROM ubuntu:trusty
MAINTAINER John Dilts <john.dilts@enstratius.com>

RUN apt-get update && apt-get install -y curl git-core supervisor

RUN curl -O -L http://graphana.s3.amazonaws.com/graphana-1.9.1.tar.gz
RUN tar xzf graphana-1.9.1.tar.gz
RUN cp -R graphana-1.9.1 /usr/share/graphana

ADD certs /tmp/ssl_certs
ADD graphana-run.sh /tmp/

ADD supervisor.conf /etc/supervisor/conf.d/supervisord.conf
EXPOSE 8888

CMD ["/tmp/graphana-run.sh"]
