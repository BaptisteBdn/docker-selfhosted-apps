# About

<p align="center">
<img src="../_utilities/wordpress.png" width="400" alt="wordpress" title="wordpress" />
</p>

WordPress is a free and open source blogging tool and a content management system (CMS) based on PHP and MySQL, which runs on a web hosting service.

* [Github](https://github.com/WordPress/WordPress)
* [Documentation](https://codex.wordpress.org/)
* [Docker Image](https://hub.docker.com/_/wordpress)

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
|-- wordpress-mysql/
`-- data/
```

- `.env` - a file containing all the environment variables used in the docker-compose.yml
- `docker-compose.yml` - a docker-compose file, use to configure your application’s services
- `wordpress-mysql/` - a directory used to store the mysql data
- `data/` - a directory used to store wordpress's data

Please make sure that all the files and directories are present.

# Information

## docker-compose
Links to the following [docker-compose.yml](docker-compose.yml) and the corresponding [.env](.env).

* docker-compose.yml
  ```yaml
  version: '3'

  services:
    db:
      image: mariadb
      container_name: wordpress-mysql
      restart: unless-stopped
      command: --transaction-isolation=READ-COMMITTED --binlog-format=ROW
      volumes:
        - ./wordpress-mysql/db:/var/lib/mysql
      environment:
        - MYSQL_ROOT_PASSWORD=${DB_ROOT_PASSWD}  # Requested, set the root's password of MySQL service.
        - MYSQL_PASSWORD=${DB_PASSWD}
        - MYSQL_DATABASE=wordpress
        - MYSQL_USER=wordpress
        - MYSQL_LOG_CONSOLE=true
      networks:
        - wordpress-net
      labels:
        # Watchtower Update
        - "com.centurylinklabs.watchtower.enable=true"

    wordpress:
      image: wordpress:latest
      container_name: wordpress
      restart: unless-stopped
      volumes:
        - ./data:/var/www/html
      networks:
        - proxy
        - wordpress-net
      depends_on:
        - db
      labels:
        - "traefik.enable=true"
        - "traefik.http.routers.wordpress.rule=Host(`${TRAEFIK_WORDPRESS}`)"
        - "traefik.http.routers.wordpress.entrypoints=https"
        - "traefik.http.routers.wordpress.tls=true"
        - "traefik.http.routers.wordpress.tls.certresolver=mydnschallenge"
        # Watchtower Update
        - "com.centurylinklabs.watchtower.enable=true"

  networks:
    wordpress-net:
    proxy:
      external: true
  ```
* .env
  ```ini
    TRAEFIK_WORDPRESS=wordpress.example.com
    DB_ROOT_PASSWD=xxxxxxxxxxxxxxx
    DB_PASSWD=xxxxxxxxxxxxxxx
  ```



# Usage

## Requirements
- [Traefik up and running](../traefik).
- A subdomain of your choice, this example uses `wordpress`.
    - You should be able to create a subdomain with your DNS provider, use a `A record` with the same IP address as your root domain.

## Configuration

Replace the environment variables in `.env` with your own.

Then replace the following variables in `data/wp-config.php`.

* DB_PASSWORD is equivalent to DB_PASSWD in `.env`
  ```
  define( 'DB_PASSWORD', 'xxxxxxxxxxxxxxx' );
  ```

* Change the following unique keys and salt, you can use this [wordpress salt generator](https://api.wordpress.org/secret-key/1.1/salt/) and copy past it
  ```
  define( 'AUTH_KEY',         'change-me' );
  define( 'SECURE_AUTH_KEY',  'change-me' );
  define( 'LOGGED_IN_KEY',    'change-me' );
  define( 'NONCE_KEY',        'change-me' );
  define( 'AUTH_SALT',        'change-me' );
  define( 'SECURE_AUTH_SALT', 'change-me' );
  define( 'LOGGED_IN_SALT',   'change-me' );
  define( 'NONCE_SALT',       'change-me' );
  ```

You can now run :

```bash
sudo docker-compose up -d
```

You should now be able to access the wordpress initialisation page.

# Update

The image is automatically updated with [watchtower](../watchtower) thanks to the following label :

```yaml
  # Watchtower Update
  - "com.centurylinklabs.watchtower.enable=true"
```
ACCESS_DENIED\
# Backup

Docker volumes are globally backed up using [borg-backup](../borg-backup). 