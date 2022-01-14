# About

<p align="center">
<img src="../_utilities/jellyfin.png" alt="jellyfin" title="jellyfin" />
</p>

Jellyfin is a Free Software Media System that puts you in control of managing and streaming your media.

* [Github](https://github.com/jellyfin/jellyfin)
* [Documentation](https://jellyfin.org/docs/)
* [Docker Image](https://hub.docker.com/r/jellyfin/jellyfin/)

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
    - [Note](#note)
- [Update](#update)
- [Backup](#backup)

<!-- /TOC -->

# Files structure 

```bash
.
|-- .env
|-- cache/
|-- config/
|-- docker-compose.yml
`-- media/
```

- `.env` - a file containing all the environment variables used in the docker-compose.yml
- `docker-compose.yml` - a docker-compose file, use to configure your application’s services
- `cache/` - a directory used to store jellyfin caching data (optionnal)
- `config/` - a directory used to store jellyfin config data
- `media/` - a directory used to store media that will be scanned by jellyfin

Please make sure that all the files and directories are present.

# Information

## docker-compose
Links to the following [docker-compose.yml](docker-compose.yml) and the corresponding [.env](.env).

* docker-compose.yml
  ```yaml
  version: '3'

  services:
    jellyfin:
      image: jellyfin/jellyfin
      container_name: jellyfin
      volumes:
          - ./config:/config
          - ./cache:/cache
          - ./media:/media
      labels:
        - "traefik.enable=true"
        - "traefik.http.routers.jellyfin.rule=Host(`${TRAEFIK_JELLYFIN}`)"
        - "traefik.http.routers.jellyfin.entrypoints=https"
        - "traefik.http.routers.jellyfin.tls=true"
        - "traefik.http.routers.jellyfin.tls.certresolver=mydnschallenge"

        # Watchtower Update
        - "com.centurylinklabs.watchtower.enable=true"
      networks:
        - proxy

  networks:
    proxy:
      external: true
  ```
* .env
  ```ini
  TRAEFIK_JELLYFIN=jellyfin.example.com
  ```

# Usage

## Requirements
- [Traefik up and running](../traefik).
- A subdomain of your choice, this example uses `jellyfin`.
    - You should be able to create a subdomain with your DNS provider, use a `A record` with the same IP address as your root domain.

## Configuration

Replace the environment variables in `.env` with your own, then run :

```bash
sudo docker-compose up -d
```

You should then be able to access the jellyfin web-ui. 

## Note

Jellyfin can be combined with [transmission](../transmission), download any media you want and watch them directly on jellyfin !
In order to do that, you can configure a volume on transmission that will link to the volume in Jellyfin or the opposite.

In transmission, you could replace 
  ```
    - ./data/downloads:/downloads
  ```
With :
  ```
    - ../jellyfin/media:/downloads
  ```

This can be configured more precisely, depending on your use-case.

# Update

The image is automatically updated with [watchtower](../watchtower) thanks to the following label :

```yaml
  # Watchtower Update
  - "com.centurylinklabs.watchtower.enable=true"
```

# Backup

Docker volumes are globally backed up using [borg-backup](../borg-backup). 

You may want to exclude the cache and media folder from the backups, add the following to [`borg-backup/excludes.txt`](../borg-backup/excludes.txt):
```
/full/path/to/jellyfin/cache
/full/path/to/jellyfin/media
```
