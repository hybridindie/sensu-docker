FROM ubuntu:trusty
MAINTAINER John Dilts <john.dilts@enstratius.com>

RUN apt-get update &&  apt-get install -y wget curl git-core supervisor

ADD certs /tmp/ssl_certs
ADD install-sensu.sh /tmp/
RUN /tmp/install-sensu.sh

ADD influxdb-setup.sh /tmp/influxdb-setup.sh
RUN /tmp/influxdb-setup.sh

ADD influxdb-run.sh /tmp/influxdb-run.sh

ADD supervisor.conf /etc/supervisor/conf.d/supervisord.conf
EXPOSE 8083
EXPOSE 8086
EXPOSE 8090
EXPOSE 8099

CMD ["/tmp/influxdb-run.sh"]
