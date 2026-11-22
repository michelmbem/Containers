# Zipkin distributed tracing server

This group runs a single Zipkin service, which includes the web interface and trace ingestion endpoints. Start with `docker compose up -d`, stop with `docker compose stop`, or remove the container with `docker compose down`. Add `-v` to remove any named volumes (none are configured for this service); add `--rmi all` to remove the image too (`docker compose down --rmi all`).

## Zipkin

Zipkin collects and displays distributed traces to help troubleshoot latency and service dependencies. Open the UI at `http://127.0.0.1:9411/zipkin`; applications can send traces to `http://127.0.0.1:9411`. The default storage is in memory, so traces do not survive container recreation.

- [Project and docs](https://zipkin.io/pages/quickstart.html) · [Docker Hub](https://hub.docker.com/r/openzipkin/zipkin) · [GitHub](https://github.com/openzipkin/zipkin)
- Isolated example: `docker run -d --name zipkin -p 127.0.0.1:9411:9411 openzipkin/zipkin:latest`
- Options: host port `9411`; no persistent volume or environment variables are set by this Compose service. Additional storage backends require explicit configuration.
