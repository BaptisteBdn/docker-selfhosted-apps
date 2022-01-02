<p align="center">
<img src="_utilities/docker.png" width="400" alt="docker" title="docker" />
</p>

Guide with example !

# Services

* [traefik](traefik/) - reverse proxy and SSL manager
* [borg-backup](borg-backup/) - backup scripts (local and AWS)
* [fail2ban](fail2ban/) - security tool (ban IP)
* [gotify](gotify/) - notification service
* [openvpn-pihole](openvpn-pihole/) - VPN with pihole (DNS sinkhole)
* [seafile](seafile/) - file-hosting software system
* [synapse-element](synapse-element/) - decentralised communication system
* [vaultwarden](vaultwarden/) - password manager
* [watchtower](watchtower/) - automatic docker images update
* [webserver](webserver/) - simple apache webserver

# Information

The overall guide is centered around example. Each of the services is tied with either a docker-compose or a script, everything has been made so that each service is almost ready to use, only a few user-specific variable are required.

All services respect a certain format :

- **About** - basic overview of the service
- **Table of Contents**
- **Files structure** - lists all the files and folder required
- **Information** - detailed information about the service and the example
- **Usage** - required configuration and commands to use the service
- **Update** - how to update the container, most of the time it is using watchtower
- **Backup** - how to back up the container, most of the time it is using borg-backup

Traefik is the core of this setup as it is the reverse proxy, it should be one of the first services to configure and use.

# Requirement

Basic linux knowledge is required and docker is a must-have, everything should be pretty easy to set up but understanding docker will make it even more easy.
Each guide gives links to the official documentation, they are usually well written, and they should answer most of your questions.

On the technical side :

* docker and docker-compose (1.X) are required, the installation process is fairly easy.
* a domain, some can be found for free but most are usually pretty cheap.

# Usage



# Other

