# OpenLDAP directory and administration UI

This group contains an OpenLDAP directory server, bootstrap entries, and LDAP Account Manager (LAM). Start with `docker compose up -d`, stop and retain directory data with `docker compose stop`, or remove containers with `docker compose down`. Add `-v` to delete the directory, bootstrap state, and LAM settings; add `--rmi all` to remove images (`docker compose down --rmi all -v` resets the group).

## OpenLDAP

OpenLDAP is an LDAP directory server. This group initializes the `addy.org` directory, sample accounts, groups, and JPEG profile photos from `bootstrap/`. It includes `mike` (Michel Mbem, `mike@local.org`, photo `pictures/mike.jpg`) in `cn=users` and `danny` (Daniel Mbem, `danny@local.org`, photo `pictures/danny.jpg`) in `cn=administrators`. Photos are stored as each user's `jpegPhoto` attribute. LDAP and LDAPS are published on loopback ports `1389` and `1636`; directory and server configuration persist in `openldap_data` and `openldap_config`.

- [Project](https://www.openldap.org/) · [GHCR image and documentation](https://github.com/intechcore/openldap) · [GitHub](https://github.com/openldap/openldap)
- Isolated example: `docker run -d --name openldap -p 127.0.0.1:1389:389 -p 127.0.0.1:1636:636 -e LDAP_ORGANISATION='Addy Organization' -e LDAP_DOMAIN=addy.org -e LDAP_ADMIN_PASSWORD=ldapadm -e LDAP_CONFIG_PASSWORD=ldapadm -e LDAP_TLS=true -e LDAP_TLS_VERIFY_CLIENT=never -v openldap_config:/etc/ldap/slapd.d -v openldap_data:/var/lib/ldap -v "$PWD/bootstrap:/bootstrap:ro" ghcr.io/intechcore/openldap:latest`
- Options: named volumes for LDAP config and directory; read-only `bootstrap/` mount; `LDAP_ORGANISATION`, `LDAP_DOMAIN`, `LDAP_ADMIN_PASSWORD`, `LDAP_CONFIG_PASSWORD`, `LDAP_TLS`, `LDAP_TLS_VERIFY_CLIENT`; LDAP ports `389`, `636`. Initial entries are applied only to empty volumes; edits to the LDIF files do not update an already initialized directory automatically.

## LDAP Account Manager

LAM is a browser application for managing LDAP users, groups, and directory configuration. Open it at `http://127.0.0.1:8080`; it is configured to connect to `openldap`.

- [Project and docs](https://www.ldap-account-manager.org/) · [GHCR image and documentation](https://github.com/LDAPAccountManager/lam) · [GitHub](https://github.com/LDAPAccountManager/lam)
- Isolated example: `docker run -d --name ldap-account-manager --network openldap_default -p 127.0.0.1:8080:80 -e LAM_PASSWORD=lamadm -e LAM_LANG=fr_FR -e LDAP_SERVER=ldap://openldap:389 -e LDAP_DOMAIN=addy.org -e LDAP_BASE_DN=dc=addy,dc=org -e LDAP_USERS_DN=ou=people,dc=addy,dc=org -e LDAP_GROUPS_DN=ou=groups,dc=addy,dc=org -e LDAP_USER=cn=admin,dc=addy,dc=org -e LAM_SKIP_PRECONFIGURE=false -v lam_config:/var/lib/ldap-account-manager/config -v lam_main_config:/etc/ldap-account-manager ghcr.io/ldapaccountmanager/lam:latest`
- Options: volumes `lam_config`, `lam_main_config`; port `80`; `LAM_PASSWORD`, language and LDAP connection/base-DN variables. Requires OpenLDAP on the same Docker network.
