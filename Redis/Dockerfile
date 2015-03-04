FROM ubuntu:trusty
MAINTAINER John Dilts <john.dilts@enstratius.com>

RUN apt-get update && apt-get upgrade -y && apt-get install -y wget openssl redis-server supervisor

ADD ssl_certs /tmp/ssl_certs
ADD setup-redis.sh /tmp/

RUN /tmp/setup-redis.sh

ADD redis-run.sh /tmp/
ADD supervisor.conf /etc/supervisor/conf.d/sensu.conf

CMD /tmp/redis-run.sh
