<p align="center">
<img src="_utilities/docker.png" width="400" alt="docker" title="docker" />
</p>

Guide with example !

# Services

* [traefik](traefik/) - reverse proxy and SSL manager
* [borg-backup](borg-backup/) - backup scripts (local and AWS)
* [fail2ban](fail2ban/) - security tool (ban IP)
* [freshrss](freshrss/) - RSS feed aggregator
* [gotify](gotify/) - notification service
* [nextcloud](nextcloud/) - file-hosting software system
* [openvpn-pihole](openvpn-pihole/) - VPN with pihole (DNS sinkhole)
* [seafile](seafile/) - file-hosting software system
* [synapse-element](synapse-element/) - decentralised communication system
* [trilium](trilium/) - hierarchical note-taking application
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

All the docker-compose provided in this repository are ready to be used, and you should not have to touch them. The only thing you need to change are the `.env` file provided with the docker-compose, they are user-specific.

To begin with, you can clone this repository on your host.

```bash
git clone https://github.com/BaptisteBdn/docker-selfhosted-apps.git
```

Provided you already have a domain, you can use the following commands to update all `.env` at once.

```bash
DOMAIN=your-domain.com
find ./ \( -name ".env" -or -name "*.yml" \) -type f -exec sed -i 's/example.com/'$DOMAIN'/g' {} \;
```

You can now go forward and try whatever service you want, every example as a `# Usage` section to guide you through the process. However, as most of them are using Traefik, it is recommended to set this one first.

# Other

## Docker images

Most images are used with the tag `latest` as it simplify the testing. It is usually not recommended running an image with this tag as it is not very dynamic and precise.
Feel free to experiment with the provided docker-compose examples and then use a better versionning system. For more information about [latest](https://vsupalov.com/docker-latest-tag/).

## Docker tools

Some useful tools to manage your private docker infrastructure.

- [lazydocker](https://github.com/jesseduffield/lazydocker) - A simple terminal UI for both docker and docker-compose, written in Go with the gocui library. By @jesseduffield
- [dive](https://github.com/wagoodman/dive) - A tool for exploring each layer in a docker image. By @anchore.
- [grype](https://github.com/anchore/grype) - A vulnerability scanner for container images and filesystems. By @anchore.

## Docker resources 

A compilation of resources mainly focus on security.

- [CIS Docker 1.13.0 Benchmark](https://downloads.cisecurity.org/#/) - provides prescriptive guidance for establishing a secure configuration posture for Docker
- [Docker security](https://docs.docker.com/engine/security/) - official docker documentation about security
- [Docker security OWASP](https://cheatsheetseries.owasp.org/cheatsheets/Docker_Security_Cheat_Sheet.html) - OWASP security cheat sheet

