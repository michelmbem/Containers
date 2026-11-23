# HashiCorp Vault secrets manager

This group runs Vault with file-based storage and its web UI. Start with `docker compose up -d`, stop while retaining Vault data and audit logs with `docker compose stop`, or remove the container and network with `docker compose down`. Named volumes `vault_file` and `vault_logs` remain in place after `down`; add `-v` to delete them (`docker compose down -v`). The server uses plain HTTP and binds to loopback for local development only. Vault must be initialized and unsealed before it can serve requests.

## Vault Server

Vault stores and controls access to secrets. Open the UI at `http://127.0.0.1:8200/ui`; the API listens on port `8200`. The server configuration is mounted read-only from `config/vault.json`; the file storage backend persists data in `vault_file`, and audit logs persist in `vault_logs`.

- [Product and documentation](https://developer.hashicorp.com/vault/docs) · [Docker deployment](https://developer.hashicorp.com/vault/docs/deploy/docker) · [Docker Hub image](https://hub.docker.com/r/hashicorp/vault) · [GitHub](https://github.com/hashicorp/vault)
- Compose example: `docker compose up -d`
- Isolated example: `docker run -d --name vault --cap-add=IPC_LOCK -p 127.0.0.1:8200:8200 -v vault_file:/vault/file -v vault_logs:/vault/logs -v "$PWD/config:/vault/config:ro" hashicorp/vault server -config=/vault/config/vault.json`
- Options: volumes `vault_file:/vault/file`, `vault_logs:/vault/logs`, and read-only config mount `./config:/vault/config:ro`; `IPC_LOCK` capability; host port `8200`; file storage path `/vault/file`; UI enabled. The file storage backend is suitable for a local single-server setup and does not provide high availability. TLS is disabled in this local example.

## Vault CLI command reference

In general, a Vault command follows this rule:

```sh
vault module operation arguments
```

Common modules and operations include:

- `operator`: `init`, `unseal`, `rekey`
- `audit`: `enable`
- `auth`: `enable`
- `secrets`: `enable`
- `kv`: `put`, `get`, `list`, `enable-versioning`, `delete`, `metadata`
- `policy`: `read`, `write`

There are also global commands such as `login`, `status`, `read`, and `write`.

## Initialize and use Vault

Run the Vault CLI in the container with `docker compose exec vault sh`. The following command sequence initializes the server, enables the audit log and a versioned KV secrets engine, and demonstrates secret operations.

1. `export VAULT_ADDR='http://127.0.0.1:8200'`
2. `vault operator init -key-shares=6 -key-threshold=3`
3. `vault operator unseal <UNSEAL KEY>` (3 times)
4. `vault status -format=json`
5. `vault login <TOKEN>`
6. `vault audit enable file file_path=/vault/logs/vault_audit.log`
7. `vault secrets enable -path=secret kv-v2`
8. `vault kv put secret/my-app/password password=123`
9. `vault kv list secret/`
10. `vault kv get secret/my-app/password`
11. `vault kv get --format=json secret/my-app/password`
12. `vault kv get -field=password secret/my-app/password`
13. `vault kv put secret/reminders/app db_username=db.ruanbekker.com username=root password=secret`
14. `vault kv get --format=json secret/reminders/app`
15. `vault kv get -field=username secret/reminders/app`
16. `vault kv delete secret/reminders`
17. `vault kv metadata put -max-versions=5 secret/fooapp/appname`
18. `vault kv metadata get secret/fooapp/appname`
19. `vault kv put secret/fooapp/appname appname=app1`
20. `vault kv put secret/fooapp/appname appname=app2`
21. `vault kv put secret/fooapp/appname appname=app3`
22. `vault kv get -field=appname secret/fooapp/appname`
23. `vault kv get -field=appname -version=2 secret/fooapp/appname`

### Initialization and unseal notes

- `vault operator init` displays 6 unseal keys and an initial root token because the command uses `-key-shares=6 -key-threshold=3`. Initialize only once for a given `vault_file` volume; keep the generated keys and root token secure.
- Run `vault operator unseal` three times with unseal keys returned by initialization. Vault must be unsealed before it can process authenticated requests.
- The token for `vault login` is the initial root token returned by `vault operator init`. For example, the command output includes a line like `Initial Root Token: hvs.DZcQGslNrf2fWMXBnNP7UYcW`.

## Jenkins integration

The config directory contains a Jenkins policy and a sample GitHub secret document. The policy is in `config/jenkins-policy.hcl`; the sample values are in `config/github.json`.

### Enable AppRole

The main setup above already enables KV v2 at `secret/`; enable the AppRole authentication method:

```sh
vault auth enable approle
```

### Create a policy and AppRole

```sh
vault policy write jenkins /vault/config/jenkins-policy.hcl
vault write auth/approle/role/jenkins token_policies="jenkins" token_ttl=1h token_max_ttl=4h
```

### Get RoleID and SecretID

```sh
vault read auth/approle/role/jenkins/role-id
vault write -f auth/approle/role/jenkins/secret-id
```

### Create the GitHub secret with three keys for a Jenkins pipeline

```sh
vault kv put secret/jenkins/github @/vault/config/github.json
```

### Read Vault secrets from a Jenkins declarative pipeline

Continue with the Jenkins integration steps described in [this article](https://codeburst.io/read-vaults-secrets-from-jenkin-s-declarative-pipeline-50a690659d6).

## Further reading

[Setup HashiCorp Vault Server on Docker and a Getting Started CLI Guide](https://blog.ruanbekker.com/blog/2019/05/06/setup-hashicorp-vault-server-on-docker-and-cli-guide/)
