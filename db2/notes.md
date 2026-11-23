# IBM Db2 Community database

This group runs IBM Db2 Community Edition, initializes the `ROASTERY` sample database from the Db2 container's `/var/custom` startup hook, and runs CloudBeaver Community. Start with `docker compose up -d`. Stop while retaining data with `docker compose stop`, or remove containers with `docker compose down`. Add `-v` to delete database, CloudBeaver, and installation-marker volumes; add `--rmi all` to remove images too (`docker compose down --rmi all -v` resets everything).

If you started the earlier version that initialized a `SAMPLE` database, recreate the stack with `docker compose down -v` before starting this configuration so Db2 initializes `ROASTERY` and the startup hook can load its schema.

## Db2 Community Edition

IBM Db2 is a relational database management system. The image initializes the `ROASTERY` database and persists database files in `db2_data`. It requires privileged mode and amd64 (emulated on Apple Silicon).

- [Product and Docker image documentation](https://www.ibm.com/docs/en/db2/12.1.x?topic=deployments-db2-community-edition-docker) · [IBM Db2 Developer Extension](https://github.com/IBM/Db2-Developer-Extension)
- Isolated example: `docker run -d --name db2 --platform linux/amd64 --privileged --shm-size=1g -p 127.0.0.1:50000:50000 -e LICENSE=accept -e DB2INSTANCE=db2inst1 -e DB2INST1_PASSWORD='Db2DevAdm1n!' -e DBNAME=ROASTERY -v db2_data:/database icr.io/db2_community/db2:latest`
- Options: persistent volume `db2_data:/database`; `LICENSE`, `DB2INSTANCE`, `DB2INST1_PASSWORD`, `DBNAME`, `BLU`, `ENABLE_ORACLE_COMPATIBILITY`, `UPDATEAVAIL`, `TO_CREATE_SAMPLEDB`, `REPODB`, `PERSISTENT_HOME`, and `HADR_ENABLED`; port `50000`. This group disables BLU, Oracle compatibility, sample database creation, repository DB, and HADR, while enabling persistent home. Community image is for non-production use.

## Db2 sample data

A startup hook runs the SQL from `scripts/01-roastery.sql` as `db2inst1` after Db2 setup completes. It creates a fictional coffee-roastery traceability dataset with farms, green-coffee lots, roast profiles/runs, cupping scores, wholesale orders, and a joined overview. A Docker volume marker prevents reinstallation after successful completion.

- [Db2 Community Docker docs](https://www.ibm.com/docs/en/db2/12.1.x?topic=deployments-db2-community-edition-docker) · [Image in IBM Container Registry](https://icr.io/db2_community/db2) · [IBM Db2 Developer Extension](https://github.com/IBM/Db2-Developer-Extension)
- The main `db2` service mounts `./custom:/var/custom:ro`, `./scripts:/scripts:ro`, and `db2_sample_state:/state`. The hook uses the initialized instance account in that same container rather than starting a second Db2 image.

## CloudBeaver Community

CloudBeaver provides a web database client at `http://127.0.0.1:3103`. Complete the administrator setup on first launch, then select the preconfigured `Db2 ROASTERY` connection. Enter `DB2INST1` and the `DB2INST1_PASSWORD` value when prompted.

- [CloudBeaver docs](https://dbeaver.com/docs/cloudbeaver/) · [Docker image](https://hub.docker.com/r/dbeaver/cloudbeaver) · [Supported databases](https://dbeaver.com/docs/cloudbeaver/Supported-databases/)
- Workspace volume: `cloudbeaver_db2_data:/opt/cloudbeaver/workspace`; datasource definition: `cloudbeaver/data-sources.json`; host port `3103` maps to CloudBeaver port `8978`. The Db2 LUW driver is included. Database credentials are requested at connection time and are not stored in the datasource file.
