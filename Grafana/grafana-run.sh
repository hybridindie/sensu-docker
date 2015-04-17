#!/bin/bash
cat << EOF > /etc/sensu/conf.d/grafana-config.json
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

sed -i -e "s/%INFLUXDB_HOST%/$INFLUXDB_EXT_IP/g" /usr/share/grafana/config.js
sed -i -e "s/%INFLUXDB_PORT%/$INFLUXDB_PORT_8086_TCP_PORT/g" /usr/share/grafana/config.js
sed -i -e "s/%INFLUXDB_GRAFANA_PASSWD%/$INFLUXDB_GRAFANA_PASSWD/g" /usr/share/grafana/config.js
sed -i -e "s/%INFLUXDB_SENSU_PASSWD%/$INFLUXDB_SENSU_PASSWD/g" /usr/share/grafana/config.js

/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
