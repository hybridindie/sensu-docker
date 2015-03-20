Sensu
============

Dockerfiles for each component and Docker Compose file for setting up a Sensu server.

Installing Docker
-----------------
Follow the instructions on the docker site for your platform.
* [CentOS](https://docs.docker.com/installation/centos/)
* [Ubuntu Trusty](https://docs.docker.com/installation/ubuntulinux/#docker-maintained-package-installation)
* [Ubuntu Precise](https://docs.docker.com/installation/ubuntulinux/#ubuntu-precise-1204-lts-64-bit)

_I recommend using the Docker maintained repos for Ubuntu and do/will not support boot2docker on OSX_

Installing Docker Compose
-------------------------

```bash
curl -L https://github.com/docker/compose/releases/download/1.1.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
```

Clone and Run the Sensu Server
------------------------------

Clone the repo ```git clone https://github.com/jbrien/sensu-docker.git```

Generate the SSL certificates for the server and clients. _This is a modified version of one provided by the Sensu Folks._ Then build and run the docker stack.

```
cd sensu-docker
./ssl_certs.sh generate
sudo docker-compose build
sudo docker-compose up
```

_it's normal to see a rc or console errors and they can safely be ignored._ once the download and build process is done you can run `sudo docker-compose up` to start the cluster. Once up browse to http://[your-server-ip]:3000/ to see the sensu dashboard.

This setup also monitors itself so you should be able to see three docker containers in the client list (the Docker container HOSTNAME is reflected in the IP Address column). Each Redis, RabbitMQ, and Sensu's components being monitored respectively. It's up to you at this point to secure the dashboard if you are going to use this in production.

_there is a metrics version in progress that can be stood up with_

```
sudo docker-compose -f sensu-metrics.yml build
sudo docker-compose -f sensu-metrics.yml up
```

_This adds Grafana and InfluxDB for metics_


Connecting a new Ubuntu Client
-----------------------

Copy the ssl_certs folder from the project root (_generated when setting up the server_) to the client along with the install_client script. If you no longer have this folder you will need to replace the certs on the server after running the script again.

make sure you have `wget` installed and run install_client.sh

```
sudo ./install_client.sh
```

Modify the client config /etc/sensu/config.json with the necessary information.

Replace `%RABBITMQ_ADDR_OR_IP%` with the address for RabbitMQ from the docker-compose launch
Replace `%NODE_NAME%` with a unique name to identify this client
Replace `%HOSTNAME%` with the hostname or IP of the client

Adjust subscriptions to meet your needs

```
{
  "rabbitmq": {
    "ssl": {
      "cert_chain_file": "/etc/sensu/ssl/cert.pem",
      "private_key_file": "/etc/sensu/ssl/key.pem"
    },
    "port": 5671,
    "host": "$RABBITMQ_ADDR",
    "user": "sensu",
    "password": "pass",
    "vhost": "/sensu"
  },
  "client": {
    "name": "sensu-metrics-grafana",
    "address": "%HOSTNAME%",
    "subscriptions": [ "default" ]
  }
}
```
