FROM  ubuntu:trusty
MAINTAINER John Dilts <john.dilts@enstratius.com>

RUN apt-get update && apt-get install -y curl wget adduser libfontconfig git-core supervisor

RUN wget https://grafanarel.s3.amazonaws.com/builds/grafana_2.0.0-beta3_amd64.deb
RUN dpkg -i grafana_2.0.0-beta3_amd64.deb

ADD https://raw.githubusercontent.com/jbrien/sensu-docker/compose/support/install-sensu.sh /tmp/
RUN chmod +x /tmp/install-sensu.sh
RUN /tmp/install-sensu.sh

ADD grafana-run.sh /tmp/

ADD supervisor.conf /etc/supervisor/conf.d/supervisord.conf

VOLUME /opt/grafana/conf
EXPOSE 3000

CMD ["/tmp/grafana-run.sh"]
