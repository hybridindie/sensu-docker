FROM ubuntu:trusty
MAINTAINER John Dilts <john.dilts@enstratius.com>

RUN apt-get update && apt-get install -y wget supervisor software-properties-common openjdk-7-jre-headless

RUN wget -qO - https://packages.elasticsearch.org/GPG-KEY-elasticsearch | apt-key add -
RUN add-apt-repository "deb http://packages.elasticsearch.org/elasticsearch/1.4/debian stable main"
RUN apt-get update && apt-get install -y elasticsearch

ADD certs /tmp/ssl_certs
ADD elasticsearch-run.sh /tmp/
ADD supervisor.conf /etc/supervisor/conf.d/supervisord.conf
EXPOSE 9200

CMD ["/tmp/elasticsearch-run.sh"]
