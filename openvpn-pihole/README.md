# About

<p align="center">
<img src="../_utilities/openvpn.svg.png" width="500" alt="openvpn" title="openvpn" /> 
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<img src="../_utilities/pihole.svg.png" width="100" alt="pihole" title="pihole" />
</p>


OpenVPN is a virtual private network (VPN), it provides you a secure, encrypted tunnel for online traffic and allow you to manage a remote private network.
Pihole is a DNS sinkhole that protects your devices from unwanted content without installing any client-side software.

* OpenVPN
  * [Github](https://github.com/OpenVPN/openvpn)
  * [Documentation](https://openvpn.net/community-resources/management-interface/)
  * [Docker Image](https://hub.docker.com/r/kylemanna/openvpn/)

* Pi-Hole
  * [Github](https://github.com/pi-hole/pi-hole)
  * [Documentation](https://docs.pi-hole.net/)
  * [Docker Image](https://hub.docker.com/r/pihole/pihole)

This guide combine both services so that every device that are connected to the VPN also pass through pihole. Having a VPN will also reinforce security for your overall infrastructure as you can combine it with [traefik IP whitelist](../traefik#Configuration).


# Table of Contents

<!-- TOC -->

- [About](#about)
- [Table of Contents](#table-of-contents)
- [File structure](#file-structure)
- [Information](#information)
    - [docker-compose](#docker-compose)
- [Usage](#usage)
    - [Requirements](#requirements)
    - [Configuration](#configuration)
    - [Pihole](#pihole)
    - [OpenVPN](#openvpn)
- [Update](#update)
- [Security](#security)
- [Backup](#backup)

<!-- /TOC -->

# Files structure 

```
.
|-- docker-compose.yml
|-- etc-dnsmasq.d/
|-- etc-pihole/
`-- openvpn-data/
```

- `docker-compose.yml` - a docker-compose file, use to configure your application’s services
- `etc-dnsmasq.d/` - a directory used to store dnsmasq configs
- `etc-pihole/` - a directory used to store your Pi-hole configs 
- `openvpn-data/` - a directory used to store openvpn data

Please make sure that all the files and directories are present.


# Information

## docker-compose
Link to the following [docker-compose.yml](docker-compose.yml).

```
version: '3'

services:
   openvpn:
     image: kylemanna/openvpn
     container_name: openvpn
     restart: unless-stopped
     cap_add:
       - NET_ADMIN
     ports:
       - "1194:1194/udp"
       - "1194:1194/tcp"
     volumes:
       - /etc/localtime:/etc/localtime:ro
       - /etc/timezone:/etc/timezone:ro
       - ./openvpn-data:/etc/openvpn
     networks:
       vpn-net:
         ipv4_address: 172.110.1.3
     labels:
      # Watchtower Update
      - "com.centurylinklabs.watchtower.enable=true"

   pihole:
     image: pihole/pihole
     container_name: pihole
     restart: unless-stopped
     cap_add:
       - NET_ADMIN
     dns:
       - 127.0.0.1
       - 1.1.1.1
     depends_on:
       - openvpn
     volumes:
       - ./etc-pihole:/etc/pihole
       - ./etc-dnsmasq.d:/etc/dnsmasq.d
       - /etc/localtime:/etc/localtime:ro
       - /etc/timezone:/etc/timezone:ro
     environment:
       TZ: Europe/Paris
     networks:
       vpn-net:
         ipv4_address: 172.110.1.4
       proxy:
     labels:
      - "traefik.enable=true"
      - "traefik.http.routers.pihole.rule=Host(`pihole.example.com`)"
      - "traefik.http.routers.pihole.entrypoints=https"
      - "traefik.http.routers.pihole.tls=true"
      - "traefik.http.routers.pihole.tls.certresolver=mydnschallenge"
      - "traefik.http.services.pihole.loadbalancer.server.port=80"
      # Watchtower Update
      - "com.centurylinklabs.watchtower.enable=true"

# docker network create --driver=bridge --subnet=172.110.1.0/24 --gateway=172.110.1.1 vpn-net
networks:
  proxy:
    external: true
  vpn-net:
    driver: bridge
    subnet: 172.110.1.0/24
    gateway: 172.110.1.1
    external: true
```

# Usage

## Requirements
- [Traefik up and running](../traefik).
- A subdomain of your choice for pihole, this example uses `pihole`.
    - You should be able to create a subdomain with your DNS provider, use a `A record` with the same IP address as your root domain.
- A subdomain of your choice for openvpn, it will allow you to use a domain name rather than an IP to configure your openvpn client. (optional)

## Configuration

No specific configuration is required, just run :

```
sudo docker-compose up -d
```

You should then be able to configure your openvpn client to use your VPN. You should also be able to access the pihole interface. 

## Pihole 

The interface is quite easy to use, but you can also check the well written official pihole [documentation](https://docs.pi-hole.net/).

## OpenVPN

* Initialize the configuration files and certificates

```bash
docker-compose run --rm openvpn ovpn_genconfig -u udp://VPN.SERVERNAME.COM
docker-compose run --rm openvpn ovpn_initpki
```

* Generate a client certificate

```bash
export CLIENTNAME="your_client_name"
# with a passphrase (recommended)
docker-compose run --rm openvpn easyrsa build-client-full $CLIENTNAME
# without a passphrase (not recommended)
docker-compose run --rm openvpn easyrsa build-client-full $CLIENTNAME nopass
```

* Retrieve the client configuration with embedded certificates

```bash
docker-compose run --rm openvpn ovpn_getclient $CLIENTNAME > $CLIENTNAME.ovpn
```

* Revoke a client certificate

```bash
# Keep the corresponding crt, key and req files.
docker-compose run --rm openvpn ovpn_revokeclient $CLIENTNAME
# Remove the corresponding crt, key and req files.
docker-compose run --rm openvpn ovpn_revokeclient $CLIENTNAME remove
```

For more information, check the openvpn docker [documentation](https://github.com/kylemanna/docker-openvpn/blob/master/docs/docker-compose.md).

# Update

The image is automatically updated with [watchtower](../watchtower) thanks to the following label :

```
      # Watchtower Update
      - "com.centurylinklabs.watchtower.enable=true"
```

# Security

Some [information](https://github.com/kylemanna/docker-openvpn#security-discussion) regarding security built in the docker image.

# Backup

Docker volumes are globally backed up using [borg-backup](../borg-backup). 