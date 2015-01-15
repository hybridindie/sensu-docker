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
    rm -rf client server ssl.json
    if [ -d "sensu_ca" ]; then
        cd sensu_ca
        rm -rf !(openssl.cnf)
    fi
}

generate() {
    mkdir -p client server sensu_ca/private sensu_ca/certs
    touch sensu_ca/index.txt
    echo 01 > sensu_ca/serial
    cd sensu_ca
    openssl req -x509 -config openssl.cnf -newkey rsa:2048 -days 1825 -out cacert.pem -outform PEM -subj /CN=SensuCA/ -nodes
    openssl x509 -in cacert.pem -out cacert.cer -outform DER
    cd ../server
    openssl genrsa -out key.pem 2048
    openssl req -new -key key.pem -out req.pem -outform PEM -subj /CN=sensu/O=server/ -nodes
    cd ../sensu_ca
    openssl ca -config openssl.cnf -in ../server/req.pem -out ../server/cert.pem -notext -batch -extensions server_ca_extensions
    cd ../server
    openssl pkcs12 -export -out keycert.p12 -in cert.pem -inkey key.pem -passout pass:secret
    cd ../client
    openssl genrsa -out key.pem 2048
    openssl req -new -key key.pem -out req.pem -outform PEM -subj /CN=sensu/O=client/ -nodes
    cd ../sensu_ca
    openssl ca -config openssl.cnf -in ../client/req.pem -out ../client/cert.pem -notext -batch -extensions client_ca_extensions
    cd ../client
    openssl pkcs12 -export -out keycert.p12 -in cert.pem -inkey key.pem -passout pass:secret
    cd ../
}

if [ "$1" = "generate" ]; then
    echo "Generating SSL certificates for Sensu ..."
    generate
elif [ "$1" = "clean" ]; then
    echo "Cleaning up ..."
    clean
else
    usage
fi
