#!/bin/bash

## -- Roles and Collections for nameserver.yaml -- ## 

# Download Roles

# This install the role by Jeff Geerling to install MySQL
ansible-galaxy role install geerlingguy.mysql --force

# This install the role by PowerDNS to install the PowerDNS Authoritative Server
ansible-galaxy role install PowerDNS.pdns --force

# Required modifications to roles to fix issues

# This removed the python-mysqldb from the PowerDNS.pdns role, as it is not supported in Debian 12
sed -i '/python-mysqldb/d' ~/.ansible/roles/PowerDNS.pdns/vars/Debian.yml

## -- End of nameserver.yaml roles and collections -- ## 

## -- Roles and Collections for proxmox.yaml -- ##

# Download Collections
ansible-galaxy collection install community.libvirt 

## -- End of proxmox.yaml roles and collections -- ##

## -- Roles and Collections for monitoring.yaml -- ##

# Download Collections

ansible-galaxy collection install ansible.posix
ansible-galaxy collection install prometheus.prometheus

## -- End of monitoring.yaml roles and collections -- ##

## -- End of kube.yaml roles and collections -- ## 

## -- Roles and Collections for kube.yaml -- ##

# Download Collections
ansible-galaxy collection install community.general

# Download Roles
ansible-galaxy role install geerlingguy.kubernetes
ansible-galaxy role install geerlingguy.containerd

## -- End of kube.yaml roles and collections -- ##


## ---------------------------------------------------------------------------------------- ##

## -- Roles and Collections for playbook.yaml -- ##

# Download Roles

# Download Collections

## -- End of playbook.yaml roles and collections -- ##