# About

<p align="center">
<img src="../_utilities/crowdsec.png" width="400" alt="crowdsec" title="crowdsec" />
</p>

CrowdSec is a free, open-source and collaborative IPS. Analyze behaviors, respond to attack & share signals across the community.

* [Github](https://github.com/crowdsecurity/crowdsec)
* [Documentation](https://doc.crowdsec.net/docs/next/intro)
* [Docker Image](https://hub.docker.com/r/crowdsecurity/crowdsec)

Crowdsec can be use as an alternative to [fail2ban](../fail2ban) if you want it too, however in this example, we are going to use it as a web/traefik IPS. We will be configuring crowdsec to protect all of our web facing services from any suspect users. Fail2ban will still be useful to protect our host.


# Table of Contents

<!-- TOC -->

- [About](#about)
- [Table of Contents](#table-of-contents)
- [Files structure](#files-structure)
- [Information](#information)
    - [docker-compose](#docker-compose)
    - [Crowdsec](#crowdsec)
    - [Traefik bouncer](#traefik-bouncer)
- [Usage](#usage)
    - [Configuration](#configuration)
    - [Crowdsec](#crowdsec)
- [Update](#update)
- [Security](#security)
- [Backup](#backup)

<!-- /TOC -->

# Files structure 
```bash
.
├── crowdsec-config/
│   └── acquis.yaml
├── crowdsec-db/
├── docker-compose.yml
└── .env
```

- `crowdsec-config/acquis.yaml` - a file containing path to the logs that crowdsec is supposed to read
- `crowdsec-db` - a directory used to store crowdsec sqlite database
- `docker-compose.yml` - a docker-compose file, use to configure your application’s services

Please make sure that all the files and directories are present.


# Information

## docker-compose
Links to the following [docker-compose.yml](docker-compose.yml) and the corresponding [.env](.env).

* docker-compose.yml
  ```yaml
    version: '3'

    services:
        crowdsec:
            image: crowdsecurity/crowdsec:latest
            container_name: crowdsec
            restart: unless-stopped
            environment:
            - COLLECTIONS="crowdsecurity/traefik"
            - GID=${PGID}
            volumes:
            - ../traefik/log:/var/log/traefik
            - ./crowdsec-config/acquis.yaml:/etc/crowdsec/acquis.yaml
            - ./crowdsec-db:/var/lib/crowdsec/data
            networks:
            - proxy

        bouncer-traefik:
            image: fbonalair/traefik-crowdsec-bouncer:latest
            container_name: crowdsec-bouncer-traefik
            restart: unless-stopped
            depends_on:
            - crowdsec
            environment:
            - CROWDSEC_BOUNCER_API_KEY=${TRAEFIK_BOUNCER_KEY}
            - CROWDSEC_AGENT_HOS=crowdsec:8080
            networks:
            - proxy    

    networks:
        proxy:
            external: true
  ```
* .env
  ```ini
    TRAEFIK_BOUNCER_KEY=xxxxxx

    # user PGID - can be found by running id your-user
    PGID=1000
  ```

## Crowdsec

## Traefik bouncer 


# Usage

## Configuration


## Crowdsec


# Update

The image is automatically updated with [watchtower](../watchtower) thanks to the following label :

```yaml
  # Watchtower Update
  - "com.centurylinklabs.watchtower.enable=true"
```

# Security



# Backup

Docker volumes are globally backed up using [borg-backup](../borg-backup). 