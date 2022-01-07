# About

<p align="center">
<img src="../_utilities/freshrss.png" alt="freshrss" title="freshrss" />
</p>

FreshRSS is a self-hosted RSS feed aggregator

* [Github](https://github.com/FreshRSS/FreshRSS)
* [Documentation](https://freshrss.github.io/FreshRSS/en/admins/01_Index.html)
* [Docker Image](https://hub.docker.com/r/linuxserver/freshrss)

# Table of Contents

<!-- TOC -->

- [About](#about)
- [Table of Contents](#table-of-contents)
- [Information](#information)
    - [docker-compose](#docker-compose)
- [Usage](#usage)
    - [Requirements](#requirements)
    - [Configuration](#configuration)
- [Update](#update)
- [Backup](#backup)

<!-- /TOC -->

```bash
.
|-- .env
|-- data/
`-- docker-compose.yml
```

* `.env` - a file containing all the environment variables used in the docker-compose.yml
* `docker-compose.yml` - a docker-compose file, use to configure your application’s services
* `data/` - a directory used to store the data

Please make sure that all the files and directories are present.

# Information

##  docker-compose

Links to the following [docker-compose.yml](docker-compose.yml) and the corresponding [.env](.env).

```yaml
version: '3'

services:
 freshrss:
    image: 'freshrss/freshrss'
    container_name: freshrss
    restart: unless-stopped
    volumes:
      - "./data:/var/www/FreshRSS/data"
    environment:
      - 'CRON_MIN=4,34'
      - 'TZ=Europe/Paris'
    networks:
      - proxy
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.webserver.rule=Host(`${TRAEFIK_FRESHRSS}`)"
      - "traefik.http.routers.webserver.entrypoints=https"
      - "traefik.http.routers.webserver.tls=true"
      - "traefik.http.routers.webserver.tls.certresolver=mydnschallenge"
      # Watchtower Update
      - "com.centurylinklabs.watchtower.enable=true"

networks:
  proxy:
    external: true
```

The docker-compose contains only one service using the freshrss image.

# Usage

## Requirements

* [Traefik up and running](../traefik).
* A subdomain of your choice, this example uses `freshrss`.
  * You should be able to create a subdomain with your DNS provider, use a `A record` with the same IP address as your root domain.

## Configuration

Before using the docker-compose file, please update the following configurations.

* **change the domain** : The current domain is example.com, change it to your domain
  
  ```bash
    sed -i -e "s/freshrss.example.com/freshrss.your-domain.com/g" docker-compose.yml 
  ```
  
You can now run :

```bash
sudo docker-compose up -d
```

# Update

The image is automatically updated with [watchtower](../watchtower) thanks to the following label :

```yaml
      # Watchtower Update
      - "com.centurylinklabs.watchtower.enable=true"
```

# Backup

Docker volumes are globally backed up using [borg-backup](../borg-backup).
