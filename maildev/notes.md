# MailDev email testing server

This group runs MailDev as a single service with an SMTP listener and browser inbox. Start with `docker compose up -d`, stop without deleting messages with `docker compose stop`, or remove the container with `docker compose down`. Add `-v` to delete saved mail; add `--rmi all` to remove the image too (`docker compose down --rmi all -v` resets the group).

## MailDev

MailDev is a local SMTP server and web interface for inspecting email sent by applications during development. Open the inbox at `http://127.0.0.1:1080` (`admin` / `admin`); SMTP is at `127.0.0.1:1025`. Other Compose services can use `maildev:1025`.

- [Project and documentation](https://maildev.github.io/maildev/) · [Docker Hub](https://hub.docker.com/r/maildev/maildev) · [GitHub](https://github.com/maildev/maildev)
- Isolated example: `docker run -d --name maildev -p 127.0.0.1:1080:1080 -p 127.0.0.1:1025:1025 -e MAILDEV_WEB_USER=admin -e MAILDEV_WEB_PASS=admin -e MAILDEV_MAIL_DIRECTORY=/home/node/mail -e MAILDEV_MAX_EMAILS=500 -v maildev_mail:/home/node/mail maildev/maildev:latest`
- Options: persistent mail volume `maildev_mail:/home/node/mail`; web and SMTP ports `1080`, `1025`; `MAILDEV_WEB_USER`, `MAILDEV_WEB_PASS`, `MAILDEV_MAIL_DIRECTORY`, `MAILDEV_MAX_EMAILS`. Credentials are local-development defaults.
