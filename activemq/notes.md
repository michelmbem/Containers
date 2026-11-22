# ActiveMQ Classic message broker

This group runs an ActiveMQ Classic broker with its web console. Start with `docker compose up -d`, stop while retaining data with `docker compose stop`, or remove the containers with `docker compose down`. Add `-v` to `down` to delete persisted broker data; add `--rmi all` to remove the images as well (`docker compose down --rmi all -v` resets everything).

## ActiveMQ Classic

ActiveMQ Classic is a message broker supporting AMQP and other messaging protocols. The web console and AMQP listener are published on loopback; broker state is stored in `activemq_data`.

- [Project](https://activemq.apache.org/components/classic/) · [Docker image](https://hub.docker.com/r/islandora/activemq) · [GitHub (image build)](https://github.com/Islandora-DevOps/isle-buildkit)
- Isolated example: `docker run -d --name activemq -p 127.0.0.1:5672:5672 -p 127.0.0.1:8161:8161 -e ACTIVEMQ_PASSWORD=amqadm -e ACTIVEMQ_WEB_ADMIN_PASSWORD=amqwebadm -v activemq_data:/opt/activemq/data islandora/activemq:main`
- Options: persistent volume `activemq_data:/opt/activemq/data`; credentials `ACTIVEMQ_PASSWORD`, `ACTIVEMQ_WEB_ADMIN_PASSWORD`; AMQP `5672`, console `8161`. Example credentials are for local development.
