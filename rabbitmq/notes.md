# RabbitMQ message broker

This group runs the RabbitMQ broker with its management plugin and web console in one service. Start with `docker compose up -d`, stop and retain broker state with `docker compose stop`, or remove the container with `docker compose down`. Add `-v` to delete broker state; add `--rmi all` to remove the image (`docker compose down --rmi all -v` resets the group).

## RabbitMQ

RabbitMQ is a message broker. AMQP is available at `127.0.0.1:5673`; the management interface is at `http://127.0.0.1:15672` with credentials `rabbit` / `rabbitadm`. State persists in `rabbitmq_data`.

- [Project and docs](https://www.rabbitmq.com/docs) · [Docker Hub](https://hub.docker.com/_/rabbitmq) · [GitHub](https://github.com/rabbitmq/rabbitmq-server)
- Isolated example: `docker run -d --name rabbitmq -p 127.0.0.1:5673:5672 -p 127.0.0.1:15672:15672 -e RABBITMQ_DEFAULT_USER=rabbit -e RABBITMQ_DEFAULT_PASS=rabbitadm -v rabbitmq_data:/var/lib/rabbitmq rabbitmq:management`
- Options: persistent volume `rabbitmq_data:/var/lib/rabbitmq`; `RABBITMQ_DEFAULT_USER`, `RABBITMQ_DEFAULT_PASS`; AMQP port `5672`, management port `15672`. Credentials are local-development values; change them before exposing the broker beyond the host.
