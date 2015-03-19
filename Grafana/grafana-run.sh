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
    "host": "$RABBITMQ_PORT_5671_TCP_ADDR",
    "user": "sensu",
    "password": "pass",
    "vhost": "/sensu"
  },
  "client": {
    "name": "sensu-metrics-grafana",
    "address": "$HOSTNAME",
    "subscriptions": [ "default", "sensu-metrics-grafana" ]
  }
}
EOF

sed -i -e "s/%INFLUXDB_HOST%/$INFLUXDB_HOST/g" \
       -e "s/%INFLUXDB_PORT%/$INFLUXDB_PORT/g" \
       /usr/share/grafana/config.js

/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
