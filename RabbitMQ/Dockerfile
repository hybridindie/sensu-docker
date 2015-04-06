FROM library/rabbitmq
MAINTAINER John Dilts <john.dilts@enstratius.com>

RUN apt-get update && apt-get install -y curl wget openssl supervisor

ADD https://raw.githubusercontent.com/jbrien/sensu-docker/restructure/support/openssl.cnf /usr/local/etc/sensu-docker
ADD https://raw.githubusercontent.com/jbrien/sensu-docker/restructure/support/install-sensu.sh /tmp/
RUN chmod +x /tmp/install-sensu.sh
RUN /tmp/install-sensu.sh

ADD rabbitmq-run.sh /tmp/
ADD supervisor.conf /etc/supervisor/conf.d/supervisord.conf

CMD ["/tmp/rabbitmq-run.sh"]
