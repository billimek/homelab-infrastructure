#!/bin/sh

TEMPLATE=9102

#####################
## K3S NODES
#####################
echo "#####################"
echo "## MASTER NODES"
echo "#####################"
qm clone "$TEMPLATE" 301 --name k3s-a
qm set 301 --sshkey ~/.ssh/id_k8s_nodes.pub
qm set 301 --ipconfig0 ip=10.2.0.31/24,gw=10.2.0.1
qm set 301 --ipconfig1 ip=10.0.10.50/24
qm move_disk 301 scsi0 zfs-prox --format=raw --delete=true

qm clone "$TEMPLATE" 302 --name k3s-b
qm set 302 --sshkey ~/.ssh/id_k8s_nodes.pub
qm set 302 --ipconfig0 ip=10.2.0.32/24,gw=10.2.0.1
qm set 302 --ipconfig1 ip=10.0.10.51/24
qm migrate 302 proxmox-b

qm clone "$TEMPLATE" 303 --name k3s-c
qm set 303 --sshkey ~/.ssh/id_k8s_nodes.pub
qm set 303 --ipconfig0 ip=10.2.0.33/24,gw=10.2.0.1
qm set 303 --ipconfig1 ip=10.0.10.52/24
qm migrate 303 proxmox-c

qm start 301
ssh proxmox-b 'qm move_disk 302 scsi0 zfs-prox --format=raw --delete=true'
ssh proxmox-b 'qm start 302'
ssh proxmox-c 'qm move_disk 303 scsi0 zfs-prox --format=raw --delete=true'
ssh proxmox-c 'qm start 303'
