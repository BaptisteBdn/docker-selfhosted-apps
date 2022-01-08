# About

<p align="center">
<img src="../_utilities/transmission.png" alt="transmission" title="transmission" />
</p>

Transmission is a fast, easy, and free BitTorrent client.

* [Github](https://github.com/transmission/transmission)
* [website](https://transmissionbt.com/)
* [Docker Image](https://hub.docker.com/r/linuxserver/transmission)

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

* docker-compose.yml
  ```yaml
  vversion: '3'

  services:
  transmission:
      image: 'linuxserver/transmission:latest'
      container_name: transmission
      restart: unless-stopped
      volumes:
        - ./data/config:/config
        - ./data/downloads:/downloads
        - ./data/watch:/watch
      environment:
        - PUID=1000
        - PGID=1000
        - TZ=${TZ}
        - USER=${USER}
        - PASS=${PASS}
      ports:
        - 51413:51413
        - 51413:51413/udp
      networks:
        - proxy
      labels:
        - "traefik.enable=true"
        - "traefik.http.routers.transmission.rule=Host(`${TRAEFIK_TRANSMISSION}`)"
        - "traefik.http.routers.transmission.entrypoints=https"
        - "traefik.http.routers.transmission.tls=true"
        - "traefik.http.routers.transmission.tls.certresolver=mydnschallenge"
        - "traefik.http.services.transmission.loadbalancer.server.port=9091"
        # Watchtower Update
        - "com.centurylinklabs.watchtower.enable=true"

  networks:
    proxy:
      external: true
  ```
* .env
  ```
  TRAEFIK_TRILIUM=transmission.example.com
  TZ=Europe/Paris
  USER=xxxxxxxxxxxxxxx
  PASS=xxxxxxxxxxxxxxx
  ```

The docker-compose contains only one service using the transmission image.

# Usage

## Requirements

* [Traefik up and running](../traefik).
* A subdomain of your choice, this example uses `transmission`.
  * You should be able to create a subdomain with your DNS provider, use a `A record` with the same IP address as your root domain.

## Configuration

Before using the docker-compose file, please update the following configurations.

* **change the domain** : The current domain is example.com, change it to your domain
  
  ```bash
    sed -i -e "s/transmission.example.com/transmission.your-domain.com/g" docker-compose.yml 
  ```

# Update

The image is automatically updated with [watchtower](../watchtower) thanks to the following label :

```yaml
      # Watchtower Update
      - "com.centurylinklabs.watchtower.enable=true"
```

# Backup

Docker volumes are globally backed up using [borg-backup](../borg-backup).
