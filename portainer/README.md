# About

<p align="center">
<img src="../_utilities/portainer.svg" alt="portainer" title="portainer" />
</p>

Portainer allows you to manage all your orchestrator resources (containers, images, volumes, networks and more) through a ‘smart’ GUI and/or an extensive API.

* [Github](https://github.com/portainer/portainer)
* [Documentation](https://docs.portainer.io/v/ce-2.11/)
* [Docker Image](https://hub.docker.com/r/portainer/portainer)

# Table of Contents

<!-- TOC -->

- [About](#about)
- [Table of Contents](#table-of-contents)
- [Information](#information)
  - [docker-compose](#docker-compose)
  - [socket-proxy](#socket-proxy)
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
version: "3"

services:
  portainer:
    image: portainer/portainer
    container_name: portainer
    restart: unless-stopped
    depends_on:
      - socket-proxy
    ports:
      - "8000:8000"
    volumes:
      - "./data:/data"
    networks:
      - proxy
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.portainer.rule=Host(`${TRAEFIK_PORTAINER}`)"
      - "traefik.http.routers.portainer.entrypoints=https"
      - "traefik.http.routers.portainer.tls=true"
      - "traefik.http.routers.portainer.tls.certresolver=mydnschallenge"
      # Watchtower Update
      - "com.centurylinklabs.watchtower.enable=true"

  socket-proxy:
    image: tecnativa/docker-socket-proxy
    container_name: portainer-socket-proxy
    restart: unless-stopped
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
    environment:
      CONTAINERS: 1
    networks:
      - proxy
    labels:
      # Watchtower Update
      - "com.centurylinklabs.watchtower.enable=true"

networks:
  proxy:
    external: true
```
* .env
  ```
  TRAEFIK_PORTAINER=portainer.example.com
  ```

The docker-compose contains two services :
- socket-proxy : This ensures Docker’s socket file to not be exposed to the public
- portainer : Portainer application configuration

## socket-proxy

The socket-proxy service is used to protect the docker socket, allowing Portainer unrestricted access to your Docker socket file could result in a vulnerability to the host computer, should any other part of the Portainer container ever be compromised. 

Instead of allowing Portainer container full access to the Docker socket file, we can instead proxy only the API calls we need with [Tecnativa’s Docker Socket Proxy](https://github.com/Tecnativa/docker-socket-proxy), following the [principle of the least privilege](https://en.wikipedia.org/wiki/Principle_of_least_privilege).

# Usage

## Requirements

* [Traefik up and running](../traefik).
* A subdomain of your choice, this example uses `portainer`.
  * You should be able to create a subdomain with your DNS provider, use a `A record` with the same IP address as your root domain.

## Configuration

Replace the environment variables in `.env` with your own, then run :

```bash
sudo docker-compose up -d
```

You should then be able to access the trilium web-ui and start creating notes !

# Update

The image is automatically updated with [watchtower](../watchtower) thanks to the following label :

```yaml
  # Watchtower Update
  - "com.centurylinklabs.watchtower.enable=true"
```

# Backup

Docker volumes are globally backed up using [borg-backup](../borg-backup).
