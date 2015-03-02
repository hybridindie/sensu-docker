#!/bin/bash
wget -q http://repos.sensuapp.org/apt/pubkey.gpg -O- | apt-key add -
echo "deb http://repos.sensuapp.org/apt sensu main" > /etc/apt/sources.list.d/sensu.list

apt-get update && apt-get install -y git-core supervisor sensu uchiwa
echo "sensu hold" | dpkg --set-selections

echo "EMBEDDED_RUBY=true" > /etc/default/sensu & ln -s /opt/sensu/embedded/bin/ruby /usr/bin/ruby
/opt/sensu/embedded/bin/gem install redphone --no-rdoc --no-ri
/opt/sensu/embedded/bin/gem install mail --no-rdoc --no-ri --version 2.5.4

rm -rf /etc/sensu/plugins
git clone https://github.com/sensu/sensu-community-plugins.git /tmp/sensu_plugins

cp -Rpf /tmp/sensu_plugins/plugins /etc/sensu/
find /etc/sensu/plugins/ -name *.rb -exec chmod +x {} \;

git clone git://github.com/opower/sensu-metrics-relay.git /tmp/sensu-metrics-relay
cp -Rpf /tmp/sensu-metrics-relay/lib/sensu/extensions/* /etc/sensu/extensions

mkdir -p /etc/sensu/ssl
cp /tmp/ssl_certs/sensu_ca/client/cert.pem /tmp/ssl_certs/sensu_ca/client/key.pem /etc/sensu/ssl
