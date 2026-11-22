FROM container-registry.oracle.com/database/sqlcl:latest

USER root
RUN if command -v microdnf >/dev/null 2>&1; then \
      microdnf install -y unzip && microdnf clean all; \
    elif command -v dnf >/dev/null 2>&1; then \
      dnf install -y unzip && dnf clean all; \
    elif command -v yum >/dev/null 2>&1; then \
      yum install -y unzip && yum clean all; \
    else \
      echo 'No supported package manager found to install unzip.' >&2; exit 1; \
    fi

COPY install-samples.sh /usr/local/bin/install-samples.sh
RUN chmod +x /usr/local/bin/install-samples.sh

ENTRYPOINT ["/usr/local/bin/install-samples.sh"]
