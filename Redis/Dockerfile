FROM ubuntu:trusty
MAINTAINER John Dilts <john.dilts@enstratius.com>

RUN apt-get update && apt-get upgrade -y && apt-get install -y wget openssl redis-server supervisor

ADD certs /tmp/ssl_certs
ADD install-sensu.sh /tmp/
RUN /tmp/install-sensu.sh

ADD redis-run.sh /tmp/
ADD supervisor.conf /etc/supervisor/conf.d/sensu.conf

CMD /tmp/redis-run.sh
