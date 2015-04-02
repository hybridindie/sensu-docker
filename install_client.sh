#!/bin/bash
wget -q http://repos.sensuapp.org/apt/pubkey.gpg -O- | apt-key add -
echo "deb http://repos.sensuapp.org/apt sensu main" > /etc/apt/sources.list.d/sensu.list

apt-get update && apt-get install -y git-core sensu
echo "sensu hold" | dpkg --set-selections

cat << EOF > /etc/default/sensu
  EMBEDDED_RUBY=true
  LOG_LEVEL=info
EOF
ln -s /opt/sensu/embedded/bin/ruby /usr/bin/ruby
/opt/sensu/embedded/bin/gem install redphone --no-rdoc --no-ri
/opt/sensu/embedded/bin/gem install mail --no-rdoc --no-ri --version 2.5.4

rm -rf /etc/sensu/plugins
git clone https://github.com/sensu/sensu-community-plugins.git /tmp/sensu_plugins

cp -Rpf /tmp/sensu_plugins/plugins /etc/sensu/
find /etc/sensu/plugins/ -name *.rb -exec chmod +x {} \;

mkdir -p /etc/sensu/ssl
cp /ssl_certs/client/cert.pem /tmp/ssl_certs/client/key.pem /etc/sensu/ssl

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
    "password": "pass",
    "vhost": "/sensu"
  },
  "client": {
    "name": "%NODE_NAME%",
    "address": "%HOSTNAME%",
    "subscriptions": [ "default", "dcm-single-node" ]
  }
}
EOF

echo "Now go and modify /etc/sensu/config.json with your Sensu RabbitMQ host and this nodes specifics."
