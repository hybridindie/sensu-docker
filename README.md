Sensu
============

Dockerfile to Create a Sensu Server

In some cases it's faster to build the docker container locally rather than pulling from the index.
`sudo docker build github.com/jbrien/sensu-docker`

Run the RabbitMQ Container https://registry.hub.docker.com/_/rabbitmq/
`docker run -d -e RABBITMQ_NODENAME=sensu --name sensu-rabbit -p 8088:15672 rabbitmq:3-management`
Port `15672` is where the rabbitmq management dashboard is running on (`un: guest pw: guest`)

Browse the RabbitMQ Management dashboard at `http://localhost:8080`

Run the Redis Container https://registry.hub.docker.com/_/redis/
`docker run --name sensu-redis -d redis`
The Docker file exposes `6379`


When you run container you can see which port the Sensu dashboard is listening on my running `docker ps` (`un: admin pw: secret`)

```
docker@ubuntu:~$ sudo docker ps
ID                  IMAGE                         COMMAND             CREATED             STATUS              PORTS
cc88c90d715e        petecheslock/sensu:0.10.2-1   /bin/bash           5 minutes ago       Up 5 minutes        15672->15672, 49158->8080
```

By default - when starting the container, docker will start all the necessary services and start sshd.

Run `sudo docker ps` to get the container ID

Then run `sudo docker inspect ${container ID}` to get the IP address of the container to connect to.

From there you can SSH to the container to inspect the running sensu processes. (`un: sensu pw: sensu`)
