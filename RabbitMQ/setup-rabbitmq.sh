rabbitmq-plugins enable rabbitmq_management
chown -R rabbitmq:rabbitmq /etc/rabbitmq/

mkdir -p /etc/rabbitmq/ssl
cp /tmp/ssl_certs/sensu_ca/cacert.pem /tmp/ssl_certs/sensu_ca/server/cert.pem /tmp/ssl_certs/sensu_ca/server/key.pem /etc/rabbitmq/ssl

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
