# About

<p align="center">
<img src="../_utilities/httpd.png" alt="httpd" title="httpd" />
</p>

The Apache HTTP Server Project is a collaborative software development effort aimed at creating a robust, commercial-grade, featureful, and freely-available source code implementation of an HTTP (Web) server. 

* [Github](https://github.com/apache/httpd)
* [Documentation](https://httpd.apache.org/docs/current/)
* [Docker Image](https://hub.docker.com/_/httpd)

Use this service in combination with Traefik to host any custom-made website you want. Portofolio, resume, blog, ...

The following example will host a simple Hello World website.

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
|-- data/
|   `-- index.html
`-- docker-compose.yml
```

- `docker-compose.yml` - a docker-compose file, use to configure your application’s services
- `data/` - a directory used to store your website content

Please make sure that all the files and directories are present.

# Information

In this example, the website will only display a Hello World as you can see in the [index.html](data/index.html).

## docker-compose
Links to the following [docker-compose.yml](docker-compose.yml).

* docker-compose.yml
  ```yaml
  version: '3'

  services:
  webserver:
      image: 'httpd:2.4'
      container_name: webserver
      restart: unless-stopped
      volumes:
        - ./data:/usr/local/apache2/htdocs/
      networks:
        - proxy
      labels:
        - "traefik.enable=true"
        - "traefik.http.routers.webserver.rule=Host(`www.example.com`)"
        - "traefik.http.routers.webserver.entrypoints=https"
        - "traefik.http.routers.webserver.tls=true"
        - "traefik.http.routers.webserver.tls.certresolver=mydnschallenge"
        # Watchtower Update
        - "com.centurylinklabs.watchtower.enable=true"

  networks:
    proxy:
      external: true
  ```
* .env
  ```ini
  TRAEFIK_WEBSERVER=www.example.com
  ```

The docker-compose contains only one service using the apache httpd image.

# Usage

## Requirements
- [Traefik up and running](../traefik).
- A subdomain of your choice, this example uses `www`.
    - You should be able to create a subdomain with your DNS provider, use a `A record` with the same IP address as your root domain.


## Configuration
Before using the docker-compose file, please update the following configurations.

- **change the domain** : The current domain is example.com, change it to your domain <br>
  ```bash
    sed -i -e "s/www.example.com/www.your-domain.com/g" docker-compose.yml 
  ```

- **change the content of the website (optional)** : Replace the content of `data` with your own website. <br>

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