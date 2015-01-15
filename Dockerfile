FROM ubuntu:trusty
MAINTAINER John Dilts <john.dilts@enstratius.com>

RUN apt-get update && apt-get upgrade -y && apt-get install -y wget openssl

RUN useradd -d /home/sensu -m -s /bin/bash sensu
RUN echo sensu:sensu | chpasswd

COPY sensu_ca /tmp/sensu_ca
WORKDIR cd /tmp/sensu_ca
RUN ssl_certs.sh generate

WORKDIR /
ADD install-sensu.sh /tmp/
RUN /tmp/install-sensu.sh

ADD supervisor.conf /etc/supervisor/conf.d/sensu.conf
ADD sensu-run.sh /tmp/sensu-run.sh

VOLUME /var/log/sensu
VOLUME /etc/sensu/conf.d

EXPOSE 4567
EXPOSE 5671
EXPOSE 6379

CMD ["mkdir", "-p", "/etc/sensu/conf.d"]
CMD ["/tmp/sensu-run.sh"]
