FROM library/rabbitmq
MAINTAINER John Dilts <john.dilts@enstratius.com>

RUN apt-get update && apt-get upgrade -y && apt-get install -y wget openssl

ADD ssl_certs /tmp/ssl_certs
ADD setup-rabbitmq.sh /tmp/
RUN /tmp/setup-rabbitmq.sh
