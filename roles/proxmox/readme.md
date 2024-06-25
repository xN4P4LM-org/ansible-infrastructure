


# WARNING: Commands in this file can break your Proxmox cluster. Use only if you know what you are doing.

### Table of Contents
- [Cluster commands](#cluster-commands)
  - [Stop node and put it in forced local mode for manual manipulation of cluster config](#stop-node-and-put-it-in-forced-local-mode-for-manual-manipulation-of-cluster-config)
    - [One liner](#one-liner)
  - [Edit corosync config](#edit-corosync-config)
  - [Rejoin node to cluster after local mode](#rejoin-node-to-cluster-after-local-mode)
  - [Fix a broken node communications](#fix-a-broken-node-communications)
  - [Set Hostname](#set-hostname)

---

## Cluster commands

### Stop node and put it in forced local mode for manual manipulation of cluster config
``` bash
systemctl stop pve-cluster
systemctl stop corosync
pmxcfs -l
```

#### One liner
``` bash
systemctl stop pve-cluster && systemctl stop corosync && pmxcfs -l
```

---
### Edit corosync config

#### Compare `/etc/corosync/corosync.conf` and `/etc/pve/corosync.conf` and make sure they are the same.

``` bash
diff /etc/corosync/corosync.conf /etc/pve/corosync.conf
```

#### If you edit `/etc/corosync/corosync.conf` you need to also copy it to `/etc/pve/corosync.conf`

``` bash
cp /etc/corosync/corosync.conf /etc/pve/corosync.conf
```

#### If you edit `/etc/pve/corosync.conf` you need to also copy it to `/etc/corosync/corosync.conf`

``` bash
cp /etc/pve/corosync.conf /etc/corosync/corosync.conf
```

---
### Rejoin node to cluster after local mode

``` bash
killall pmxcfs
systemctl start corosync
systemctl start pve-cluster
```


### Fix a broken node communications

``` bash
rm /etc/pve/authkey.pub
rm /etc/pve/priv/authkey.key
rm /etc/pve/priv/authorized_keys
rm /etc/pve/pve-root-ca.pem
rm /etc/pve/priv/pve-root-ca.key
rm /etc/pve/nodes/*/pve-ssl.pem
pvecm updatecerts -f
systemctl restart pvedaemon pveproxy
```

### Set Hostname

```bash
hostnamectl hostname 
hostnamectl hostname --static 
hostnamectl hostname --pretty "Proxmox Hypervisor Node: "
```

```bash
export HOSTNAME=$(hostname -s)

hostnamectl hostname $HOSTNAME.proxmox.xn4p4lm.net
hostnamectl hostname --static $HOSTNAME.proxmox.xn4p4lm.net
hostnamectl hostname --pretty "Proxmox Hypervisor Node: $HOSTNAME"
```

# Create a template from a cloud image


## 1. create the vm
``` bash
qm create 1011 --bios ovmf --ciuser xn4p4lm  \
--name debian-12 --memory 1024 --net0 virtio,bridge=vmbr0 --numa 0 --sockets 1 \
--cores 1 --machine q35 --ostype l26 --rng0 /dev/urandom --agent enabled=1,fstrim_cloned_disks=1 --cpu cputype=x86-64-v4 --tags template
```

## 2. create the efi disk
``` bash
qm set 1011 --efidisk0 peridot:1,efitype=4m,pre-enrolled-keys=1
```

## 3. create the cloud-init drive
``` bash
qm set 1011 --ide2 peridot:cloudinit
```

## 4. create the tpm state disk
``` bash
qm set 1011 -tpmstate0 peridot:1,version=v2.0
```

## 5. create the vm disk
``` bash
qm set 1011 --scsihw virtio-scsi-single \
--scsi0 peridot:0,import-from=/root/cloud-images/debian-12.qcow2,aio=native,iothread=1,ssd=1
```

## 6. set boot order
``` bash
qm set 1011 --boot c --bootdisk scsi0
```
