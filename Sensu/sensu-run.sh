#!/bin/sh
UCHIWA_USER=${UCHIWA_USER:-admin}
UCHIWA_PASS=${UCHIWA_PASS:-sensu}
SENSU_HOST=${SENSU_HOST:-localhost}
UCHIWA_CONFIG_URL=${UCHIWA_CONFIG_URL:-}
SKIP_CONFIG=${SKIP_CONFIG:-}
SENSU_METRICS=${SENSU_METRICS:-}
SENSU_CONFIG_URL=${SENSU_CONFIG_URL:-}
SENSU_CLIENT_CONFIG_URL=${SENSU_CLIENT_CONFIG_URL:-}

if [ ! -z "$SENSU_CONFIG_URL" ] ; then
  wget --no-check-certificate -O /etc/sensu/config.json $SENSU_CONFIG_URL
else
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
    "redis": {
      "host": "$REDIS_PORT_6379_TCP_ADDR",
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
      "address": "$HOSTNAME",
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

cat << EOF > /etc/sensu/conf.d/sensu-client.json
  {
     "checks": {
        "sensu-client": {
          "handlers": [
          "default"
          ],
          "command": "/etc/sensu/plugins/processes/check-procs.rb -p sensu-client -C 1 -w 4 -c 5",
          "interval": 60,
          "occurrences": 2,
          "refresh": 300,
          "subscribers": [ "default" ]
        }
     }
  }
EOF

cat << EOF > /etc/sensu/conf.d/sensu-server.json
  {
    "checks": {
      "sensu-server": {
        "handlers": [
          "default"
        ],
        "command": "/etc/sensu/plugins/processes/check-procs.rb -p sensu-server -C 1 -w 4 -c 5",
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
      "uchiwa": {
        "handlers": [
          "default"
        ],
        "command": "/etc/sensu/plugins/processes/check-procs.rb -p uchiwa -C 1 -w 1 -c 1",
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
        "subscribers": [ "sensu-redis" ]
      },
      "sensu-rabbitmq-beam": {
        "handlers": [
        "default"
        ],
        "command": "/etc/sensu/plugins/processes/check-procs.rb -p beam -C 1 -w 4 -c 5",
        "interval": 60,
        "occurrences": 2,
        "refresh": 300,
        "subscribers": [ "sensu-rabbitmq" ]
      },
      "sensu-rabbitmq-epmd": {
        "handlers": [
        "default"
        ],
        "command": "/etc/sensu/plugins/processes/check-procs.rb -p epmd -C 1 -w 1 -c 1",
        "interval": 60,
        "occurrences": 2,
        "refresh": 300,
        "subscribers": [ "sensu-rabbitmq" ]
      }
    }
  }
EOF
if [ ! -z "$SENSU_METRICS" ] ; then
  cat << EOF > /etc/sensu/conf.d/config-relay.json
  {
    "relay": {
      "graphite": {
        "host": "$GRAPHITE_PORT_2003_TCP_ADDR",
        "port": "$GRAPHITE_PORT_2003_TCP_PORT"
      }
    }
  }
EOF
  echo "Wrote out /etc/sensu/conf.d/config-relay.json"

  cat << EOF > /etc/sensu/conf.d/sensu-metrics.json
  {
    "checks": {
      "sensu-metrics-graphite": {
        "handlers": [
          "default"
        ],
        "command": "/etc/sensu/plugins/processes/check-procs.rb -p carbon-cache -C 1 -w 4 -c 5",
        "interval": 60,
        "occurrences": 2,
        "refresh": 300,
        "subscribers": [ "sensu-metrics-graphite" ]
      },
      "sensu-metrics-elasticsearch": {
        "handlers": [
          "default"
        ],
        "command": "/etc/sensu/plugins/processes/check-procs.rb -p elasticsearch -C 1 -w 4 -c 5",
        "interval": 60,
        "occurrences": 2,
        "refresh": 300,
        "subscribers": [ "sensu-metrics-elasticsearch" ]
      },
      "sensu-metrics-apache2": {
        "handlers": [
          "default"
        ],
        "command": "/etc/sensu/plugins/processes/check-procs.rb -p apache2 -C 1 -w 4 -c 5",
        "interval": 60,
        "occurrences": 2,
        "refresh": 300,
        "subscribers": [ "sensu-metrics-graphite", "sensu-metrics-grafana" ]
      }
    }
  }
EOF
  echo "Wrote out /etc/sensu/conf.d/sensu-metrics.json"
fi

/usr/bin/supervisord -c /etc/supervisor/conf.d/sensu.conf
