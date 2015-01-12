#!/bin/bash
apt-get -y install erlang-nox
echo "deb http://www.rabbitmq.com/debian/ testing main" > /etc/apt/sources.list.d/rabbitmq.list

curl -L -o ~/rabbitmq-signing-key-public.asc http://www.rabbitmq.com/rabbitmq-signing-key-public.asc
apt-key add ~/rabbitmq-signing-key-public.asc

apt-get update
apt-get -y --allow-unauthenticated --force-yes install rabbitmq-server

chown -R rabbitmq:rabbitmq /etc/rabbitmq/

mkdir -p /etc/rabbitmq/ssl
cp /sensu_ca/cacert.pem /etc/rabbitmq/ssl
cp /server/*.pem /etc/rabbitmq/ssl

/etc/init.d/rabbitmq-server restart

rabbitmqctl add_vhost /sensu

rabbitmqctl add_user sensu sensu
rabbitmqctl set_permissions -p /sensu sensu ".*" ".*" ".*"
rabbitmq-plugins enable rabbitmq_management

apt-get -y install redis-server

wget -q http://repos.sensuapp.org/apt/pubkey.gpg -O- | apt-key add -
echo "deb     http://repos.sensuapp.org/apt sensu main" > /etc/apt/sources.list.d/sensu.list

apt-get update
apt-get install sensu uchiwa

chown -R sensu:sensu /etc/sensu/
