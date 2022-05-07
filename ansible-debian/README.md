# About

<p align="center">
<img src="../_utilities/ansible.svg.png" width="300" alt="Ansible" title="Ansible" />
</p>

Ansible is an IT automation tool. It can configure systems, deploy software, and orchestrate more advanced IT tasks such as continuous deployments or zero downtime rolling updates.

* [Github](https://github.com/ansible/ansible)
* [Documentation](https://docs.ansible.com/ansible/latest/index.html)

We are going to be using Ansible to set up our server, it will install docker as well as UFW (Uncomplicated Firewall).

This playbook has been tested on debian and should work far any debian like distribution.

# Table of Contents

<!-- TOC -->

- [About](#about)
- [Table of Contents](#table-of-contents)
- [Information](#information)
    - [Docker](#docker)
    - [UFW](#ufw)
- [Usage](#usage)
    - [Requirements](#requirements)
    - [Configuration](#configuration)
    - [Notes](#notes)

<!-- /TOC -->


# Information

This ansible playbook uses two roles : geerlingguy.docker and ufw.

## Docker

The docker role is made by [geerlingguy](https://github.com/geerlingguy/ansible-role-docker), it installs Docker on Linux.

## UFW

[The Uncomplicated Firewall](https://wiki.ubuntu.com/UncomplicatedFirewall) (ufw) is a frontend for iptables. UFW provides a framework for managing netfilter, as well as a command-line interface for manipulating the firewall.
However, when Docker is installed, Docker bypass the UFW rules and the published ports can be accessed from outside, rendering UFW useless.
Chaifeng found a [solution](https://github.com/chaifeng/ufw-docker) by modifying only one UFW configuration file, all Docker configurations and options remain the default.
This playbook does a few things :
- Install UFW 
- Apply Chaifeng fix to prevent docker bypassing UFW
- Open port for OpenSSH from anywhere
- Open port 80 and 443 (with and without forwarding) from anywhere
- Deny every other incoming requests

# Usage

## Requirements

- ansible installed
- ansible geerlingguy.docker role installed
    ```
    ansible-galaxy install geerlingguy.docker
    ```
-   ansible community.general installed (for UFW)
    ```
    ansible-galaxy collection install community.general
    ```

## Configuration

To use the playbook, modify the [hosts](hosts) file with your own remote host (IP or DNS).

Then run :

```
ansible-playbook --inventory hosts main.yml
```

If you are using a specific user with a specific key you can use the following extra-vars :

```
ansible-playbook --inventory hosts --extra-vars "ansible_ssh_user=your-user ansible_ssh_private_key_file=/path/to/your/key.pem" main.yml
```

If you want to use the playbook on localhost, run :

```
ansible-playbook --connection=local --inventory 127.0.0.1, main.yml
```

You can check that docker and UFW are installed by running :

```
docker --version
ufw --version
```

## Notes

You can check that UFW is up and running with : 

```
sudo ufw status verbose
```

You should have the following : 
```
Status: active
Logging: on (low)
Default: deny (incoming), allow (outgoing), deny (routed)
New profiles: skip

To                         Action      From
--                         ------      ----
OpenSSH/tcp                ALLOW IN    Anywhere
80,443/tcp                 ALLOW IN    Anywhere
OpenSSH/tcp (v6)           ALLOW IN    Anywhere (v6)
80,443/tcp (v6)            ALLOW IN    Anywhere (v6)

80/tcp                     ALLOW FWD   Anywhere
443/tcp                    ALLOW FWD   Anywhere
80/tcp (v6)                ALLOW FWD   Anywhere (v6)
443/tcp (v6)               ALLOW FWD   Anywhere (v6)
```

UFW logs are available in `/var/log/ufw.log`.