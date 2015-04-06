#!/bin/bash
/opt/sensu/embedded/bin/gem install influxdb --no-rdoc --no-ri
apt-get install -y git-core sensu uchiwa

mkdir -p /etc/sensu/ssl
echo $CLIENT_CERT >> /etc/sensu/ssl/cert.pem
echo $CLIENT_KEY >> /etc/sensu/ssl/key.pem
