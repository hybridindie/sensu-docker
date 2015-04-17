#!/bin/bash
cat << EOF > /etc/sensu/docker-config.json
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
    "name": "sensu-metrics-influxdb",
    "address": "$HOSTNAME",
    "subscriptions": [ "default", "sensu-metrics-influxdb" ]
  }
}
EOF

/etc/init.d/influxdb start

until (curl -X POST 'http://localhost:8086/cluster_admins/root?u=root&p=root' \
            -d '{"password": "'"$INFLUXDB_ROOT_PASSWD"'"}' 2>/dev/null) \
            do sleep 1; done
echo 'Changed "root" password'

until (curl -X POST 'http://localhost:8086/db?u=root&p='"$INFLUXDB_ROOT_PASSWD" \
            -d '{"name": "sensu"}' 2>/dev/null) do sleep 1; done
echo 'Created database "sensu"'

until (curl -X POST 'http://localhost:8086/db/sensu/users?u=root&p='"$INFLUXDB_ROOT_PASSWD" \
            -d '{"name": "sensu", "password": "'"$INFLUXDB_SENSU_PASSWD"'"}' 2>/dev/null) \
            do sleep 1; done
echo 'Created User "sensu"'

until (curl -X POST 'http://localhost:8086/db?u=root&p='"$INFLUXDB_ROOT_PASSWD" \
            -d '{"name": "grafana"}' 2>/dev/null) do sleep 1; done
echo 'Created database "grafana"'

until (curl -X POST 'http://localhost:8086/db/grafana/users?u=root&p='"$INFLUXDB_ROOT_PASSWD" \
            -d '{"name": "grafana", "password": "'"$INFLUXDB_GRAFANA_PASSWD"'"}' 2>/dev/null) \
            do sleep 1; done
echo 'Created User "grafana"'

/etc/init.d/influxdb stop
sleep 3

/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
