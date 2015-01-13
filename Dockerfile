FROM ubuntu:trusty
MAINTAINER John Dilts <john.dilts@enstratius.com>

RUN apt-get update && apt-get install -y wget openssl

RUN useradd -d /home/sensu -m -s /bin/bash sensu
RUN echo sensu:sensu | chpasswd

ADD sensu_ca sensu_ca
ADD ssl_certs.sh /tmp/
RUN /tmp/ssl_certs.sh generate

ADD install-sensu.sh /tmp/
RUN /tmp/install-sensu.sh

ADD supervisor.conf /etc/supervisor/conf.d/sensu.conf
ADD sensu-run.sh /tmp/sensu-run.sh

VOLUME /etc/sensu
VOLUME /var/log/sensu

EXPOSE 4567
EXPOSE 5672
EXPOSE 6379
EXPOSE 3000

CMD /tmp/sensu-run.sh
