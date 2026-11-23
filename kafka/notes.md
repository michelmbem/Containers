# Apache Kafka single-node event streaming

This group runs Apache Kafka in single-node KRaft mode and Kafbat UI. Start with `docker compose up -d`, stop and keep broker data with `docker compose stop`, or remove containers with `docker compose down`. Add `-v` to delete broker data; add `--rmi all` to remove images (`docker compose down --rmi all -v` resets the stack).

## Apache Kafka

Kafka is a distributed event-streaming platform. This local single-node setup combines the broker and controller. Host clients use `localhost:9092`; other Compose services use `kafka-server:19092`. Broker data persists in `kafka_data_v2`, mounted at `/var/lib/kafka/data` so the image's `appuser` can write to it.

- [Project and docs](https://kafka.apache.org/documentation/) · [Docker Hub](https://hub.docker.com/r/apache/kafka) · [GitHub](https://github.com/apache/kafka)
- Isolated example: `docker run -d --name kafka-server -p 127.0.0.1:9092:9092 -e KAFKA_NODE_ID=1 -e KAFKA_PROCESS_ROLES=broker,controller -e KAFKA_LISTENERS='CONTROLLER://:29093,PLAINTEXT_HOST://:9092,PLAINTEXT://:19092' -e KAFKA_ADVERTISED_LISTENERS='PLAINTEXT_HOST://localhost:9092,PLAINTEXT://kafka-server:19092' -e KAFKA_LISTENER_SECURITY_PROTOCOL_MAP='CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT,PLAINTEXT_HOST:PLAINTEXT' -e KAFKA_CONTROLLER_QUORUM_VOTERS=1@kafka-server:29093 -e KAFKA_CONTROLLER_LISTENER_NAMES=CONTROLLER -e KAFKA_INTER_BROKER_LISTENER_NAME=PLAINTEXT -e CLUSTER_ID=4L6g3nShT-eMCtK--X86sw -e KAFKA_LOG_DIRS=/var/lib/kafka/data -v kafka_data_v2:/var/lib/kafka/data apache/kafka:4.4.0`
- Options: persistent volume `kafka_data_v2:/var/lib/kafka/data`; the command shows node, role, listeners, controller quorum and cluster ID. Compose also sets `KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR`, `KAFKA_GROUP_INITIAL_REBALANCE_DELAY_MS`, `KAFKA_TRANSACTION_STATE_LOG_MIN_ISR`, `KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR`, and `KAFKA_LOG_DIRS`; host port `9092`. Plaintext and single-node replication settings are for a local sandbox.

## Kafbat UI

Web interface for inspecting Kafka clusters, topics, consumer groups, and messages. Available at `http://127.0.0.1:9090`; preconfigured for this broker.

- [Project and docs](https://ui.docs.kafbat.io/) · [GitHub Container Registry](https://github.com/orgs/kafbat/packages/container/package/kafka-ui) · [GitHub](https://github.com/kafbat/kafka-ui)
- Isolated example: `docker run -d --name kafka-ui --network kafka_default -p 127.0.0.1:9090:8080 -e KAFKA_CLUSTERS_0_BOOTSTRAPSERVERS=kafka-server:19092 -e KAFKA_CLUSTERS_0_NAME=local-kafka-cluster ghcr.io/kafbat/kafka-ui:v1.5.0`
- Options: port `8080`; `KAFKA_CLUSTERS_0_BOOTSTRAPSERVERS`, `KAFKA_CLUSTERS_0_NAME`; requires the Kafka broker on the same Docker network.
