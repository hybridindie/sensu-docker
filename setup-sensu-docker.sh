#!/bin/bash

shopt -s extglob

usage() {
    cat <<EOF
usage: $0 option

OPTIONS:
   help       Show this message
   clean      Clean up
   generate   Generate SSL certificates for Sensu
EOF
}

clean() {
  rm -rf /usr/local/etc/sensu-docker
}

setup() {
  workdir=$(pwd)
  mkdir /usr/local/etc/sensu-docker && cd /usr/local/etc/sensu-docker
  mkdir -p client server sensu_ca/private sensu_ca/certs
  cd $workdir
}

generate_ssl() {
  workdir=$(pwd)
  cd /usr/local/etc/sensu-docker
  passwd=$(openssl rand -base64 32 | base64 | head -c 24 ; echo)
  rm sensu_ca/index.txt sensu_ca/serial
  touch sensu_ca/index.txt
  echo 01 > sensu_ca/serial
  cd sensu_ca
  openssl req -x509 -config $workdir/support/openssl.cnf -newkey rsa:2048 -days 1825 -out cacert.pem -outform PEM -subj /CN=SensuCA/ -nodes
  openssl x509 -in cacert.pem -out cacert.cer -outform DER
  cd ../server
  openssl genrsa -out key.pem 2048
  openssl req -new -key key.pem -out req.pem -outform PEM -subj /CN=sensu/O=server/ -nodes
  cd ../sensu_ca
  openssl ca -config $workdir/support/openssl.cnf -in ../server/req.pem -out ../server/cert.pem -notext -batch -extensions server_ca_extensions
  cd ../server
  openssl pkcs12 -export -out keycert.p12 -in cert.pem -inkey key.pem -passout pass:$passwd
  cd ../client
  openssl genrsa -out key.pem 2048
  openssl req -new -key key.pem -out req.pem -outform PEM -subj /CN=sensu/O=client/ -nodes
  cd ../sensu_ca
  openssl ca -config $workdir/support/openssl.cnf -in ../client/req.pem -out ../client/cert.pem -notext -batch -extensions client_ca_extensions
  cd ../client
  openssl pkcs12 -export -out keycert.p12 -in cert.pem -inkey key.pem -passout pass:$passwd
  cd ../
}

generate_environment() {
  cat << EOF > /usr/local/etc/sensu-docker/sensu.env
RABBITMQ_PASSWD=$(openssl rand -base64 32 | base64 | head -c 24 ; echo)
INFLUXDB_PASSWD=$(openssl rand -base64 32 | base64 | head -c 24 ; echo)
INFLUXDB_ROOT_PASSWD=$(openssl rand -base64 32 | base64 | head -c 24 ; echo)
EOF
}

if [ "$1" = "generate" ]; then
    echo "Setting up Sensu..."
    setup
    echo "Generating SSL certificates for Sensu ..."
    generate_ssl
    echo "Creating docker environment..."
    generate_environment
elif [ "$1" = "clean" ]; then
    echo "Cleaning up ..."
    clean
else
    usage
fi
