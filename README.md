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

cd to the clone folder and run `sudo docker-compose build` this will pull and build the containers locally. _it's normal to see a rc or console errors and they can safely be ignored._ once the download and build process is done you can run `sudo docker-compose up` to start the cluster. Once up browse to http://[your-server-ip]:3000/ to see the sensu dashboard.

This setup also monitors itself so you should be able to see three docker containers in the client list (the Docker container HOSTNAME is reflected in the IP Address column). Each Redis, RabbitMQ, and Sensu's components being monitored respectively. It's up to you at this point to secure the dashboard if you are going to use this in production.

Connecting a new Client
-----------------------
