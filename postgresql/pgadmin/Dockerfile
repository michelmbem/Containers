FROM dpage/pgadmin4:latest

USER root

RUN apk add --no-cache gettext

COPY startup.sh /startup.sh
COPY servers.json.template /servers.json.template

RUN chmod +x /startup.sh

ENTRYPOINT ["/startup.sh"]

