#!/bin/bash
mkdir -p /etc/sensu/ssl
cp /tmp/ssl_certs/client/cert.pem /tmp/ssl_certs/client/key.pem /etc/sensu/ssl

cat << EOF > /etc/sensu/config.json
{
  "rabbitmq": {
    "ssl": {
      "cert_chain_file": "/etc/sensu/ssl/cert.pem",
      "private_key_file": "/etc/sensu/ssl/key.pem"
    },
    "port": 5671,
    "host": "localhost",
    "user": "sensu",
    "password": "pass",
    "vhost": "/sensu"
  },
  "client": {
    "name": "sensu-rabbitmq",
    "address": "$HOSTNAME",
    "subscriptions": [ "default", "sensu-rabbitmq" ]
  }
}
EOF

rabbitmq-plugins enable rabbitmq_management
chown -R rabbitmq:rabbitmq /etc/rabbitmq/

mkdir -p /etc/rabbitmq/ssl
cp /tmp/ssl_certs/sensu_ca/cacert.pem /tmp/ssl_certs/server/cert.pem /tmp/ssl_certs/server/key.pem /etc/rabbitmq/ssl

cat << EOF > /etc/rabbitmq/rabbitmq.config
[
  {rabbit, [
    {default_vhost,       <<"/sensu">>},
    {default_user,        <<"sensu">>},
    {default_pass,        <<"pass">>},
    {default_permissions, [<<".*">>, <<".*">>, <<".*">>]},
    {ssl_listeners, [5671]},
      {ssl_options, [{cacertfile,"/etc/rabbitmq/ssl/cacert.pem"},
                     {certfile,"/etc/rabbitmq/ssl/cert.pem"},
                     {keyfile,"/etc/rabbitmq/ssl/key.pem"},
                     {verify,verify_peer},
                     {fail_if_no_peer_cert,true}]}
  ]}
].
EOF
