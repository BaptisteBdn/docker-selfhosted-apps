# About

<p align="center">
<img src="../_utilities/redmine.png" width="400" alt="redmine" title="redmine" />
</p>

Redmine is a flexible project management web application written using Ruby on Rails framework.

* [Github](https://github.com/redmine/redmine)
* [Documentation](https://www.redmine.org/)
* [Docker Image](https://hub.docker.com/_/redmine)

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
- [Backup](#backup)

<!-- /TOC -->

# Files structure 

```bash
.
|-- .env
|-- docker-compose.yml
|-- redmine-mysql/
`-- data/
```

- `.env` - a file containing all the environment variables used in the docker-compose.yml
- `docker-compose.yml` - a docker-compose file, use to configure your application’s services
- `redmine-mysql/` - a directory used to store the mysql data
- `data/` - a directory used to store redmine's data

Please make sure that all the files and directories are present.

# Information

## docker-compose
Links to the following [docker-compose.yml](docker-compose.yml) and the corresponding [.env](.env).

* docker-compose.yml
  ```yaml
    version: '3'

    services:
    db:
        image: mysql:5.7
        container_name: redmine-mysql
        restart: unless-stopped
        volumes:
        - ./redmine-mysql/db:/var/lib/mysql
        environment:
        - MYSQL_ROOT_PASSWORD=${DB_ROOT_PASSWD}  # Requested, set the root's password of MySQL service.
        - MYSQL_PASSWORD=${DB_PASSWD}
        - MYSQL_DATABASE=redmine
        - MYSQL_USER=redmine
        - MYSQL_LOG_CONSOLE=true
        networks:
        - redmine-net
        labels:
        # Watchtower Update
        - "com.centurylinklabs.watchtower.enable=true"

    redmine:
        image: redmine:latest
        container_name: redmine
        restart: unless-stopped
        volumes:
        - ./data/files:/usr/src/redmine/files
        - ./data/plugins:/usr/src/redmine/plugins
        - ./data/themes:/usr/src/redmine/public/themes
        environment:
        - REDMINE_DB_MYSQL=redmine-mysql
        - REDMINE_DB_PASSWORD=${DB_ROOT_PASSWD}
        networks:
        - proxy
        - redmine-net
        depends_on:
        - db
        labels:
        - "traefik.enable=true"
        - "traefik.http.routers.redmine.rule=Host(`${TRAEFIK_REDMINE}`)"
        - "traefik.http.routers.redmine.entrypoints=https"
        - "traefik.http.routers.redmine.tls=true"
        - "traefik.http.routers.redmine.tls.certresolver=mydnschallenge"
        # Watchtower Update
        - "com.centurylinklabs.watchtower.enable=true"
        # Ip filtering
        - "traefik.http.routers.redmine.middlewares=whitelist@file"

    networks:
    redmine-net:
    proxy:
        external: true
  ```
* .env
  ```ini
    TRAEFIK_REDMINE=redmine.example.com
    DB_ROOT_PASSWD=xxxxxxxxxxxxxxx
    DB_PASSWD=xxxxxxxxxxxxxxx
  ```



# Usage

## Requirements
- [Traefik up and running](../traefik).
- A subdomain of your choice, this example uses `redmine`.
    - You should be able to create a subdomain with your DNS provider, use a `A record` with the same IP address as your root domain.

## Configuration

Replace the environment variables in `.env` with your own, then run :

```bash
sudo docker-compose up -d
```

You should now be able to access the redmine login page. The default credentials are : `admin`, `admin`.


# Update

The image is automatically updated with [watchtower](../watchtower) thanks to the following label :

```yaml
  # Watchtower Update
  - "com.centurylinklabs.watchtower.enable=true"
```

# Backup

Docker volumes are globally backed up using [borg-backup](../borg-backup). 