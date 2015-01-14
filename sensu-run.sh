#!/bin/sh
UCHIWA_USER=${UCHIWA_USER:-admin}
UCHIWA_PASS=${UCHIWA_PASS:-sensu}
SENSU_HOST=${SENSU_HOST:-localhost}
UCHIWA_CONFIG_URL=${UCHIWA_CONFIG_URL:-localhost}
SKIP_CONFIG=${SKIP_CONFIG:-}
SENSU_CONFIG_URL=${SENSU_CONFIG_URL:-}
SENSU_CLIENT_CONFIG_URL=${SENSU_CLIENT_CONFIG_URL:-}
SENSU_CHECKS_CONFIG_URL=${SENSU_CHECKS_CONFIG_URL:-}

if [ ! -z "$SENSU_CONFIG_URL" ] ; then
  wget --no-check-certificate -O /etc/sensu/config.json $SENSU_CONFIG_URL
else
  cat << EOF > /etc/sensu/config.json
  {
    "rabbitmq": {
      "port": 5672,
      "host": "$SENSU_HOST",
      "user": "guest",
      "password": "guest",
      "vhost": "/"
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
    }
  }
EOF
  echo "Wrote out /etc/sensu/config.json"
fi

if [ ! -z "$SENSU_CLIENT_CONFIG_URL" ] ; then
  wget --no-check-certificate -O /etc/sensu/conf.d/client.json $SENSU_CLIENT_CONFIG_URL
else
  cat << EOF > /etc/sensu/conf.d/client.json
  {
    "client": {
      "name": "sensu-server",
      "address": "127.0.0.1",
      "subscriptions": [ "default", "sensu" ]
    }
  }
EOF
  echo "Wrote out /etc/sensu/conf.d/client.json"
fi

if [ ! -z "$UCHIWA_CONFIG_URL" ] ; then
  wget --no-check-certificate -O /etc/sensu/uchiwa.json $SENSU_CLIENT_CONFIG_URL
else
  cat << EOF > /etc/sensu/sensu-uchiwa.json
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
        "host": "$SENSU_HOST",
        "port": 3000,
        "user": "$UCHIWA_USER",
        "password": "$UCHIWA_PASS",
        "refresh": 5
      }
    }
EOF
  echo "Wrote out /etc/sensu/conf.d/client.json"
fi

if [ ! -z "$SENSU_CHECKS_CONFIG_URL" ] ; then
  wget --no-check-certificate -O /etc/sensu/conf.d/checks.json $SENSU_CHECKS_CONFIG_URL
else
  cat << EOF > /etc/sensu/conf.d/checks.json
  {
    "checks": {
      "sensu-rabbitmq-beam": {
        "handlers": [
        "default"
        ],
        "command": "/etc/sensu/plugins/processes/check-procs.rb -p beam -C 1 -w 4 -c 5",
        "interval": 60,
        "occurrences": 2,
        "refresh": 300,
        "subscribers": [ "sensu" ]
      },
      "sensu-rabbitmq-epmd": {
        "handlers": [
        "default"
        ],
        "command": "/etc/sensu/plugins/processes/check-procs.rb -p epmd -C 1 -w 1 -c 1",
        "interval": 60,
        "occurrences": 2,
        "refresh": 300,
        "subscribers": [ "sensu" ]
      },
      "sensu-redis": {
        "handlers": [
        "default"
        ],
        "command": "/etc/sensu/plugins/processes/check-procs.rb -p redis-server -C 1 -w 4 -c 5",
        "interval": 60,
        "occurrences": 2,
        "refresh": 300,
        "subscribers": [ "sensu" ]
      },
      "sensu-api": {
        "handlers": [
        "default"
        ],
        "command": "/etc/sensu/plugins/processes/check-procs.rb -p sensu-api -C 1 -w 4 -c 5",
        "interval": 60,
        "occurrences": 2,
        "refresh": 300,
        "subscribers": [ "sensu" ]
      },
      "sensu-ctl": {
        "handlers": [
        "default"
        ],
        "command": "/etc/sensu/plugins/processes/check-procs.rb -p sensu-ctl -C 1 -w 1 -c 1",
        "interval": 60,
        "occurrences": 2,
        "refresh": 300,
        "subscribers": [ "sensu" ]
      },
      "uchiwa": {
        "handlers": [
        "default"
        ],
        "command": "/etc/sensu/plugins/processes/check-procs.rb -p uchiwa -C 1 -w 1 -c 1",
        "interval": 60,
        "occurrences": 2,
        "refresh": 300,
        "subscribers": [ "sensu" ]
      }
    }
  }
EOF
  echo "Wrote out /etc/sensu/conf.d/checks.json"
fi

/usr/bin/supervisord
