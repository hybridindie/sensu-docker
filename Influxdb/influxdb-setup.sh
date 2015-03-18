#!/bin/bash
if [ -f "/.influxdb_configured" ]; then
  echo "InfluxDB already to go"
else
  wget http://s3.amazonaws.com/influxdb/influxdb_latest_amd64.deb
  dpkg -i influxdb_latest_amd64.deb

  /etc/init.d/influxdb start

  until (curl -X POST 'http://localhost:8086/db?u=root&p=root' \
              -d '{"name": "sensu"}' 2>/dev/null) do sleep 1; done
  echo 'Created database "sensu"'

  until (curl -X POST 'http://localhost:8086/db?u=root&p=root' \
              -d '{"name": "grafana"}' 2>/dev/null) do sleep 1; done
  echo 'Created database "grafana"'

  /etc/init.d/influxdb stop

  touch "/.influxdb_configured"

  exit 0
fi

exit 0
