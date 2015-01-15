#!/bin/sh
UCHIWA_USER=${UCHIWA_USER:-admin}
UCHIWA_PASS=${UCHIWA_PASS:-sensu}
SENSU_HOST=${SENSU_HOST:-localhost}
UCHIWA_CONFIG_URL=${UCHIWA_CONFIG_URL:-}
SKIP_CONFIG=${SKIP_CONFIG:-}
SENSU_CONFIG_URL=${SENSU_CONFIG_URL:-}
SENSU_CLIENT_CONFIG_URL=${SENSU_CLIENT_CONFIG_URL:-}

if [ ! -z "$SENSU_CONFIG_URL" ] ; then
  wget --no-check-certificate -O /etc/sensu/config.json $SENSU_CONFIG_URL
else
  cat << EOF > /etc/sensu/config.json
  {
    "rabbitmq": {
      "port": 5671,
      "host": "$SENSU_HOST",
      "user": "sensu",
      "password": "sensu",
      "vhost": "/sensu"
    },
    "redis": {
      "host": "$SENSU_HOST",
      "port": 6379
    },
    "api": {
      "host": "$SENSU_HOST",
      "port": 4567
    },
    "handlers": {
      "default": {
        "type": "pipe",
        "command": "true"
      }
    },
    "client": {
      "name": "sensu-server",
      "address": "127.0.0.1",
      "subscriptions": [ "default", "sensu" ]
    }
  }
EOF
  echo "Wrote out /etc/sensu/config.json"
fi

if [ ! -z "$UCHIWA_CONFIG_URL" ] ; then
  wget --no-check-certificate -O /etc/sensu/uchiwa.json $UCHIWA_CONFIG_URL
else
  cat << EOF > /etc/sensu/uchiwa.json
    {
      "sensu": [
        {
          "name": "Sensu",
          "host": "$SENSU_HOST",
          "ssl": false,
          "port": 4567,
          "user": "",
          "pass": "",
          "path": "",
          "timeout": 5000
        }
      ],
      "uchiwa": {
        "host": "0.0.0.0",
        "port": 3000,
        "user": "$UCHIWA_USER",
        "password": "$UCHIWA_PASS",
        "refresh": 5
      }
    }
EOF
  echo "Wrote out /etc/sensu/uchiwa.json"
fi

/usr/bin/supervisord
