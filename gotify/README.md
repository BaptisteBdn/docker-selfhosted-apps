# About

<p align="center">
<img src="../_utilities/gotify.png" width="400" alt="gotify" title="gotify" />
</p>

Gotify is a simple server for sending and receiving notification messages. It is used a lot throughout this guide for services such as backups and automatic updates, a must-have self-hosted solution.

* [Github](https://github.com/gotify/server)
* [Documentation](https://gotify.net/docs/index)
* [Docker Image](https://hub.docker.com/r/gotify/server)

# Table of Contents

<!-- TOC -->

- [About](#about)
- [Table of Contents](#table-of-contents)
- [Files structure](#files-structure)
- [Information](#information)
    - [docker-compose](#docker-compose)
- [Usage](#usage)
    - [Requirements](#requirements)
    - [Configuration](#configuration)
- [Update](#update)
- [Security](#security)
- [Backup](#backup)

<!-- /TOC -->

# Files structure 

```bash
.
|-- .env
|-- docker-compose.yml
`-- data/
```

- `.env` - a file containing all the environment variables used in the docker-compose.yml
- `docker-compose.yml` - a docker-compose file, use to configure your application’s services
- `data/` - a directory used to store the service's data

Please make sure that all the files and directories are present.


# Information

## docker-compose
Links to the following [docker-compose.yml](docker-compose.yml) and the corresponding [.env](.env).

* docker-compose.yml
  ```yaml
  version: "3"

  services:
    gotify:
      image: gotify/server
      container_name: gotify
      restart: unless-stopped
      volumes:
        - "./data:/app/data"
      environment:
        - GOTIFY_DEFAULTUSER_PASS=${GOTIFY_DEFAULTUSER_PASS}
      networks:
        - proxy
      labels:
        - "traefik.enable=true"
        - "traefik.http.routers.gotify.rule=Host(`gotify.example.com`)"
        - "traefik.http.routers.gotify.entrypoints=https"
        - "traefik.http.routers.gotify.tls=true"
        - "traefik.http.routers.gotify.tls.certresolver=mydnschallenge"

        # Watchtower Update
        - "com.centurylinklabs.watchtower.enable=true"

  networks:
    proxy:
      external: true
  ```
* .env
  ```ini
  TRAEFIK_GOTIFY=gotify.example.com
  GOTIFY_DEFAULTUSER_PASS=xxxxxxxxxxxxxxxxx
  ```

# Usage

## Requirements
- [Traefik up and running](../traefik).
- A subdomain of your choice, this example uses `gotify`.
    - You should be able to create a subdomain with your DNS provider, use a `A record` with the same IP address as your root domain.

## Configuration

Replace the environment variables in `.env` with your own, then run :

```bash
sudo docker-compose up -d
```

You should then be able to access the gotify web-ui with the default user being `admin` and the GOTIFY_DEFAULTUSER_PASS defined in `.env`.

# Update

The image is automatically updated with [watchtower](../watchtower) thanks to the following label :

```yaml
  # Watchtower Update
  - "com.centurylinklabs.watchtower.enable=true"
```

# Security

Don't forget to change the GOTIFY_DEFAULTUSER_PASS after first using it.

# Backup

Docker volumes are globally backed up using [borg-backup](../borg-backup). 