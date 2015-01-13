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

Run the Sensu server
`docker run --name sensu-server -p 3000:3000 --link sensu-rabbit --link sensu-redis -d johnd/sensu`
When you run container you can see which port the Sensu dashboard is listening on my running `docker ps` (`un: admin pw: secret`)
