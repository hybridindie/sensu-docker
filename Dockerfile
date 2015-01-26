FROM ubuntu:trusty
MAINTAINER John Dilts <john.dilts@enstratius.com>

RUN apt-get update && apt-get upgrade -y && apt-get install -y wget openssl

RUN useradd -d /home/sensu -m -s /bin/bash sensu
RUN echo sensu:sensu | chpasswd

ADD ssl_certs /tmp/ssl_certs
ADD install-sensu.sh /tmp/
RUN /tmp/install-sensu.sh

ADD supervisor.conf /etc/supervisor/conf.d/sensu.conf
ADD sensu-run.sh /tmp/sensu-run.sh

RUN service rabbitmq-server start

CMD ["rabbitmqctl", "add_vhost", "/sensu"]
CMD ["rabbitmqctl", "add_user", "sensu", "pass"]
CMD ["rabbitmqctl", "set_permissions", "-p", "/sensu", "sensu", "\".*\"", "\".*\"", "\".*\""]

VOLUME /var/log/sensu
VOLUME /etc/sensu/conf.d

EXPOSE 4567
EXPOSE 5671
EXPOSE 6379

CMD ["mkdir", "-p", "/etc/sensu/conf.d"]
CMD ["/tmp/sensu-run.sh"]
