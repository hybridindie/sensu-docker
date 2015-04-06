#!/bin/bash
if [ -f "/usr/local/etc/sensu-docker/sensu_ca/serial" ]; then
  echo "Certificates already generated"
else
  mkdir /usr/local/etc/sensu-docker && cd /usr/local/etc/sensu-docker
  mkdir -p client server sensu_ca/private sensu_ca/certs
  passwd=$(openssl rand -base64 32 | base64 | head -c 24 ; echo)
  touch sensu_ca/index.txt
  echo 01 > sensu_ca/serial
  cd sensu_ca
  openssl req -x509 -config /usr/local/etc/sensu-docker/openssl.cnf -newkey rsa:2048 -days 1825 -out cacert.pem -outform PEM -subj /CN=SensuCA/ -nodes
  openssl x509 -in cacert.pem -out cacert.cer -outform DER
  cd ../server
  openssl genrsa -out key.pem 2048
  openssl req -new -key key.pem -out req.pem -outform PEM -subj /CN=sensu/O=server/ -nodes
  cd ../sensu_ca
  openssl ca -config /usr/local/etc/sensu-docker/openssl.cnf -in ../server/req.pem -out ../server/cert.pem -batch -extensions server_ca_extensions
  cd ../server
  openssl pkcs12 -export -out keycert.p12 -in cert.pem -inkey key.pem -passout pass:$passwd
  cd ../client
  openssl genrsa -out key.pem 2048
  openssl req -new -key key.pem -out req.pem -outform PEM -subj /CN=sensu/O=client/ -nodes
  cd ../sensu_ca
  openssl ca -config /usr/local/etc/sensu-docker/openssl.cnf -in ../client/req.pem -out ../client/cert.pem -batch -extensions client_ca_extensions
  cd ../client
  openssl pkcs12 -export -out keycert.p12 -in cert.pem -inkey key.pem -passout pass:$passwd
  cd ../../
fi

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
