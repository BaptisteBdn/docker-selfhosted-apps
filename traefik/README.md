# About

<p align="center">
<img src="../_utilities/traefik.logo.png" alt="Traefik" title="Traefik" />
</p>

Traefik is a modern HTTP reverse proxy and load balancer that makes deploying microservices easy. 
It is an Edge Router, it means that it's the door to your platform, and that it intercepts and routes every incoming request.

Traefik is a key component for this selfhosted infrastructure, it is providing the following features :

- Act as a reverse proxy, enabling you to selfhosted multiple services behind a single IP
- HTTPS for your services by leveraging Let's Encrypt
- Easily configure TLS for all services
- Use a whitelist to restrict services to a fix set of IPs

Requirements :
- Domain, we will use example.com for this guide.
- DNS manager, usually it goes with the provider you used for your domain. We will use OVH for the guide. List of compatible [providers](https://doc.traefik.io/traefik/https/acme/#providers).
- Ports 80 and 443 open, check your firewall.

# Table of Contents

<!-- TOC -->

- [About](#about)
- [Table of Contents](#table-of-contents)
- [File structure](#file-structure)
- [Informations](#informations)
    - [docker-compose](#docker-compose)
    - [socket-proxy](#socket-proxy)
    - [traefik](#traefik)
        - [DNS Challenge with Let's Encrypt](#dns-challenge-with-lets-encrypt)
        - [Global redirect to HTTPS](#global-redirect-to-https)
        - [Redirect root to www](#redirect-root-to-www)
- [Usage](#usage)
- [Update](#update)
- [Security](#security)
- [Backup](#backup)

<!-- /TOC -->

# File structure 

```
.
|-- .env
|-- docker-compose.yml
|-- letsencrypt/
|-- rules/
|   |-- tls.yml
|   `-- whitelist.yml
`-- traefik.yml
```

- `.env` - a file containing all the environment variables used in the docker-compose.yml
- `docker-compose.yml` - a docker-compose file, use to configure your application’s services
- `letsencrypt/` - a directory used to store the certificates informations
- `rules/` - a directory used to store traefik optionnal rules (TLS, IP whitelist)
- `traefik.yml` - traefik configuration file

Please make sure that all the files and directory are present.

# Informations

Traefik has multiple ways to be configure, I will be using two of them for this guide :
- Configuration file : Such as traefik.yml, tls.yml, ...
- Labels : Used in a docker-compose file

The configuration could be done using only one of the two method, but I find it easy to use files for standard configurations that should almost never change and labels to allow a more dynamic configuration.

## docker-compose
Links to the following [docker-compose.yml](docker-compose.yml) and the corresponding [.env](.env).
```
version: "3"

services:
  traefik:
    image: "traefik:latest"
    container_name: "traefik"
    restart: unless-stopped
    depends_on:
      - socket-proxy
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - "./traefik.yml:/traefik.yml:ro"
      - "./rules:/rules:ro"
      - "./letsencrypt:/letsencrypt"
    environment:
      - OVH_ENDPOINT=${OVH_ENDPOINT}
      - OVH_APPLICATION_KEY=${OVH_APPLICATION_KEY}
      - OVH_APPLICATION_SECRET=${OVH_APPLICATION_SECRET}
      - OVH_CONSUMER_KEY=${OVH_CONSUMER_KEY}
    networks:
      - proxy
    labels:
      - "traefik.enable=true"

      # global redirect to https
      - "traefik.http.routers.http-catchall.rule=hostregexp(`{host:.+}`)"
      - "traefik.http.routers.http-catchall.entrypoints=http"
      - "traefik.http.routers.http-catchall.middlewares=redirect-to-https"

      # middleware redirect
      - "traefik.http.middlewares.redirect-to-https.redirectscheme.scheme=https"
      - "traefik.http.middlewares.redirect-to-https.redirectscheme.permanent=true"

      # redirect root to www
      - "traefik.http.routers.root.rule=host(`example.com`)"
      - "traefik.http.routers.root.entrypoints=https"
      - "traefik.http.routers.root.middlewares=redirect-root-to-www"
      - "traefik.http.routers.root.tls=true"

      # middleware redirect root to www
      - "traefik.http.middlewares.redirect-root-to-www.redirectregex.regex=^https://example\\.com/(.*)"
      - "traefik.http.middlewares.redirect-root-to-www.redirectregex.replacement=https://www.example.com/$${1}"

      # Watchtower Update
      - "com.centurylinklabs.watchtower.enable=true"

  socket-proxy:
    image: tecnativa/docker-socket-proxy
    container_name: traefik-socket-proxy
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

The docker-compose contains two services :
- socket-proxy : This ensures Docker’s socket file to not be exposed to the public
- traefik : Traefik application configuration

## socket-proxy

The socket-proxy service is used to protect the docker socket, allowing Traefik unrestricted access to your Docker socket file could result in a vulnerability to the host computer, as per [Traefik own documentation](https://doc.traefik.io/traefik/providers/docker/#docker-api-access), should any other part of the Traefik container ever be compromised. 

Instead of allowing Traefik container full access to the Docker socket file, we can instead proxy only the API calls we need with [Tecnativa’s Docker Socket Proxy](https://github.com/Tecnativa/docker-socket-proxy), following the [principle of least privilege](https://en.wikipedia.org/wiki/Principle_of_least_privilege).

## traefik

### DNS Challenge with Let's Encrypt

Traefik can use an ACME provider (like Let's Encrypt) for automatic certificate generation. It will create the certificate and attempt to renew it automatically 30 days before expiration.

For the DNS challenge, you'll need a [working provider](https://doc.traefik.io/traefik/https/acme/#providers) along with the credentials allowing to create and remove DNS records.


### Global redirect to HTTPS

```
      # global redirect to https
      - "traefik.http.routers.http-catchall.rule=hostregexp(`{host:.+}`)"
      - "traefik.http.routers.http-catchall.entrypoints=http"
      - "traefik.http.routers.http-catchall.middlewares=redirect-to-https"
```
This rule will match all the HTTP requests and redirect them to HTTPS. It uses the redirect-to-https middleware.

### Redirect root to www

```
      # redirect root to www
      - "traefik.http.routers.root.rule=host(`example.com`)"
      - "traefik.http.routers.root.entrypoints=https"
      - "traefik.http.routers.root.middlewares=redirect-root-to-www"
      - "traefik.http.routers.root.tls=true"
```
This rule will automatically redirect the root domain `example.com` to `www.example.com`. You can use the [webserver](../webserver) example to setup a website using docker. 

# Usage


# Update

# Security

# Backup