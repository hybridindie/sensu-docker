#!/bin/bash
wget -q http://repos.sensuapp.org/apt/pubkey.gpg -O- | apt-key add -
echo "deb http://repos.sensuapp.org/apt sensu main" > /etc/apt/sources.list.d/sensu.list

apt-get update && apt-get install -y git-core sensu
echo "sensu hold" | dpkg --set-selections

cat << EOF > /etc/default/sensu
  EMBEDDED_RUBY=true
  LOG_LEVEL=info
EOF
ln -sf /opt/sensu/embedded/bin/ruby /usr/bin/ruby
/opt/sensu/embedded/bin/gem install redphone --no-rdoc --no-ri
/opt/sensu/embedded/bin/gem install mail --no-rdoc --no-ri --version 2.5.4

rm -rf /etc/sensu/plugins
git clone https://github.com/sensu/sensu-community-plugins.git /tmp/sensu_plugins

cp -Rpf /tmp/sensu_plugins/plugins /etc/sensu/
find /etc/sensu/plugins/ -name *.rb -exec chmod +x {} \;

mkdir -p /etc/sensu/ssl

cat << EOF > /etc/sensu/config.json
{one se
  "rabbitmq": {
    "ssl": {
      "cert_chain_file": "/etc/sensu/ssl/cert.pem",
      "private_key_file": "/etc/sensu/ssl/key.pem"
    },
    "port": 5671,
    "host": "%RABBITMQ_ADDR_OR_IP%",
    "user": "sensu",
    "password": "%RABBITMQ_PASSWD%",
    "vhost": "/sensu"
  },
  "client": {
    "name": "%NODE_NAME%",
    "address": "%HOSTNAME%",
    "subscriptions": [ "default" ]
  }
}
EOF

echo "Next steps are:"
echo "* Retrieve the RabbitMQ password from /usr/local/etc/sensu-docker/sensu.env on the server."
echo "* modify /etc/sensu/config.json with your Sensu RabbitMQ host and password."
echo "* Create a unique name and add the hostname of this node for the 'client' section of /etc/sensu/config.json."
echo "* mkdir -p /etc/sensu/ssl"
echo "* copy /usr/local/etc/client/{cert,key}.pem from the server to /etc/sensu/ssl"
echo "* sudo service sensu-client start"
echo ""
echo "Now watch the Uchiwa dashbard of the server for the node to join."
