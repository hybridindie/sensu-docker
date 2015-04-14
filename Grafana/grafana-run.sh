#!/bin/bash
cat << EOF > /etc/sensu/config.json
{
  "rabbitmq": {
    "ssl": {
      "cert_chain_file": "/usr/local/etc/sensu-docker/client/cert.pem",
      "private_key_file": "/usr/local/etc/sensu-docker/client/key.pem"
    },
    "port": 5671,
    "host": "$RABBITMQ_PORT_5671_TCP_ADDR",
    "user": "sensu",
    "password": "$RABBITMQ_PASSWD",
    "vhost": "/sensu"
  },
  "client": {
    "name": "sensu-metrics-grafana",
    "address": "$HOSTNAME",
    "subscriptions": [ "default", "sensu-metrics-grafana" ]
  }
}
EOF

/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
