#!/bin/bash
cat << EOF > /etc/sensu/docker-config.json
{
  "rabbitmq": {
    "ssl": {
      "cert_chain_file": "/usr/local/etc/sensu-docker/client/cert.pem",
      "private_key_file": "/usr/local/etc/sensu-docker/client/key.pem"
    },
    "port": 5671,
    "host": "localhost",
    "user": "sensu",
    "password": "$RABBITMQ_PASSWD",
    "vhost": "/sensu"
  },
  "client": {
    "name": "sensu-rabbitmq",
    "address": "$HOSTNAME",
    "subscriptions": [ "default", "sensu-rabbitmq" ]
  }
}
EOF

chown -R rabbitmq:rabbitmq /etc/rabbitmq/

cat << EOF > /etc/rabbitmq/rabbitmq.config
[
  {rabbit, [
    {default_vhost,       <<"/sensu">>},
    {default_user,        <<"sensu">>},
    {default_pass,        <<"$RABBITMQ_PASSWD">>},
    {default_permissions, [<<".*">>, <<".*">>, <<".*">>]},
    {ssl_listeners, [5671]},
      {ssl_options, [{cacertfile,"/usr/local/etc/sensu-docker/sensu_ca/cacert.pem"},
                     {certfile,"/usr/local/etc/sensu-docker/server/cert.pem"},
                     {keyfile,"/usr/local/etc/sensu-docker/server/key.pem"},
                     {verify,verify_peer},
                     {fail_if_no_peer_cert,true}]}
  ]}
].
EOF

/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
