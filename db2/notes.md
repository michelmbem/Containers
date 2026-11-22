# IBM Db2 Community database

This group runs IBM Db2 Community Edition and a one-shot installer for the `ROASTERY` sample database. Start with `docker compose up -d`; the installer waits for Db2 to become healthy, loads the sample schema and data, then exits. Stop while retaining data with `docker compose stop`, or remove containers with `docker compose down`. Add `-v` to delete database and installation-marker volumes; add `--rmi all` to remove the image too (`docker compose down --rmi all -v` resets everything).

If you started the earlier version that initialized a `SAMPLE` database, recreate the stack with `docker compose down -v` before starting this configuration so Db2 initializes `ROASTERY` and the installer can load its schema.

## Db2 Community Edition

IBM Db2 is a relational database management system. The image initializes the `ROASTERY` database and persists database files in `db2_data`. It requires privileged mode and amd64 (emulated on Apple Silicon).

- [Product and Docker image documentation](https://www.ibm.com/docs/en/db2/12.1.x?topic=deployments-db2-community-edition-docker) · [IBM Db2 Developer Extension](https://github.com/IBM/Db2-Developer-Extension)
- Isolated example: `docker run -d --name db2 --platform linux/amd64 --privileged --shm-size=1g -p 127.0.0.1:50000:50000 -e LICENSE=accept -e DB2INSTANCE=db2inst1 -e DB2INST1_PASSWORD='Db2DevAdm1n!' -e DBNAME=ROASTERY -v db2_data:/database icr.io/db2_community/db2:latest`
- Options: persistent volume `db2_data:/database`; `LICENSE`, `DB2INSTANCE`, `DB2INST1_PASSWORD`, `DBNAME`, `BLU`, `ENABLE_ORACLE_COMPATIBILITY`, `UPDATEAVAIL`, `TO_CREATE_SAMPLEDB`, `REPODB`, `PERSISTENT_HOME`, and `HADR_ENABLED`; port `50000`. This group disables BLU, Oracle compatibility, sample database creation, repository DB, and HADR, while enabling persistent home. Community image is for non-production use.

## Db2 sample installer (`install-samples`, one-shot)

A temporary service waits for Db2 health and runs the SQL from `scripts/01-roastery.sql` against the `ROASTERY` database. It creates a fictional coffee-roastery traceability dataset with farms, green-coffee lots, roast profiles/runs, cupping scores, wholesale orders, and a joined overview. A Docker volume marker prevents reinstallation after successful completion.

- [Db2 Community Docker docs](https://www.ibm.com/docs/en/db2/12.1.x?topic=deployments-db2-community-edition-docker) · [Image in IBM Container Registry](https://icr.io/db2_community/db2) · [IBM Db2 Developer Extension](https://github.com/IBM/Db2-Developer-Extension)
- Compose-managed example: `docker compose run --rm install-samples` (automatically included in `docker compose up -d`)
- Options: mounts `db2_data:/database` to reuse the initialized Db2 instance client catalog, `./scripts:/scripts:ro`, and `db2_sample_state:/state`; environment `LICENSE`, `DB2INSTANCE`, `DB2INST1_PASSWORD`; runs on `linux/amd64` and requires a healthy `db2` service. Remove the exited service container with `docker compose rm -f install-samples`; the state marker remains in its named volume.
