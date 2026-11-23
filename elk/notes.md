# Elasticsearch, Kibana and Logstash observability stack

This group contains Elasticsearch, Kibana, Logstash, and a one-shot setup service that provisions Kibana's service account. The stack uses the shared version `8.19.25`. If `.env` is missing, copy `.env-template` to `.env` and set `ELASTIC_PASSWORD` and `KIBANA_PASSWORD`; this checkout has a local `.env` with generated values, ignored by Git. Start with `docker compose up -d`; stop with `docker compose stop` or remove containers with `docker compose down`. Add `-v` to remove Elasticsearch data; add `--rmi all` to remove images (`docker compose down --rmi all -v` resets the stack).

## Elasticsearch

Distributed search and analytics engine. The stack pins a shared version through `STACK_VERSION`; its data persists in `elasticsearch_data`.

- [Product](https://www.elastic.co/elasticsearch) · [Docker docs](https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html) · [Image](https://www.docker.elastic.co/r/elasticsearch) · [GitHub](https://github.com/elastic/elasticsearch)
- Isolated example: `docker run -d --name elasticsearch -p 127.0.0.1:9200:9200 -e discovery.type=single-node -e xpack.security.http.ssl.enabled=false -e ELASTIC_PASSWORD='<password>' -e ES_JAVA_OPTS='-Xms512m -Xmx512m' -v elasticsearch_data:/usr/share/elasticsearch/data docker.elastic.co/elasticsearch/elasticsearch:<version>`
- Options: persistent data volume; `discovery.type`, `cluster.name`, `bootstrap.memory_lock`, `xpack.security.http.ssl.enabled`, `ES_JAVA_OPTS`, and `ELASTIC_PASSWORD`. Set `STACK_VERSION` consistently for all Elastic services; Compose requires `ELASTIC_PASSWORD` and `KIBANA_PASSWORD`. Use the `elastic` account to sign in to Kibana; its password is `ELASTIC_PASSWORD` in `.env`. Plain HTTP is local-development only.

## Kibana

Web interface for exploring Elasticsearch data, dashboards, and operational tools. In this group it is reachable at `http://127.0.0.1:5601` and uses the `kibana_system` account provisioned by `setup`.

- [Product](https://www.elastic.co/kibana) · [Docker docs](https://www.elastic.co/guide/en/kibana/current/docker.html) · [Image](https://www.docker.elastic.co/r/kibana) · [GitHub](https://github.com/elastic/kibana)
- Isolated example: `docker run --rm --network elk_default -p 127.0.0.1:5601:5601 -e ELASTICSEARCH_HOSTS=http://elasticsearch:9200 -e ELASTICSEARCH_USERNAME=kibana_system -e ELASTICSEARCH_PASSWORD='<password>' docker.elastic.co/kibana/kibana:<version>`
- Options: port `5601`; environment `ELASTICSEARCH_HOSTS`, `ELASTICSEARCH_USERNAME`, `ELASTICSEARCH_PASSWORD`, `TELEMETRY_ENABLED`. It requires a reachable Elasticsearch service.

## Logstash

Data collection and transformation pipeline. It reads the repository's `logstash.conf`, accepts JSON over TCP at `127.0.0.1:5044`, and indexes events in Elasticsearch.

- [Product](https://www.elastic.co/logstash) · [Docker docs](https://www.elastic.co/guide/en/logstash/current/docker.html) · [Image](https://www.docker.elastic.co/r/logstash) · [GitHub](https://github.com/elastic/logstash)
- Isolated example: `docker run --rm --network elk_default -p 127.0.0.1:5044:5044 -e ELASTIC_HOSTS=http://elasticsearch:9200 -e ELASTIC_PASSWORD='<password>' -v "$PWD/logstash.conf:/usr/share/logstash/pipeline/logstash.conf:ro" docker.elastic.co/logstash/logstash:<version>`
- Options: read-only pipeline bind mount `./logstash.conf`; port `5044`; `ELASTIC_HOSTS`, `ELASTIC_PASSWORD`. It requires Elasticsearch.

## Elasticsearch setup service (one-shot)

An Elasticsearch image runs a short command to set the password for Kibana's service account, then exits successfully. Compose runs it before Kibana and Logstash.

- [Elasticsearch image documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html) · [Image](https://www.docker.elastic.co/r/elasticsearch) · [GitHub](https://github.com/elastic/elasticsearch)
- Compose-managed example: `docker compose run --rm setup`
- Options: requires healthy Elasticsearch and `ELASTIC_PASSWORD` plus `KIBANA_PASSWORD`; this one-shot provisioning step is not intended to run independently of the stack.
