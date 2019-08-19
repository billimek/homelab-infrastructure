# Kubernetes nodes in proxmox

![](https://i.imgur.com/O4e6ev0.png)

On `proxmox` host OS:

## Base template

Creating the base template:

```shell
qm create 9101 --memory 4096 --cores 4 --cpu cputype=host --net0 virtio,bridge=vmbr0,tag=20 --net1 virtio,bridge=vmbr1
qm importdisk 9101 /tank/data/ubuntu-18.10-server-cloudimg-amd64.img proxmox
qm set 9101 --scsihw virtio-scsi-pci --scsi0 proxmox:9101/vm-9101-disk-0.raw,ssd=1,discard=on
qm resize 9101 scsi0 32G
qm set 9101 --ide2 proxmox:cloudinit
qm set 9101 --boot c --bootdisk scsi0
qm set 9101 --serial0 socket --vga serial0
qm set 9101 --ostype l26
qm set 9101 --agent enabled=1,fstrim_cloned_disks=1
qm template 9101
```

## K3S specific template

Based on the above base, create the k3s template:

```shell
qm clone 9101 9102 --name k3s-template
qm set 9102 --sshkey ~/.ssh/id_rsa.pub
qm set 9102 --ipconfig0 ip=dhcp
qm set 9102 --ipconfig1 ip=10.0.10.50/24
```

Enhance the k3s template with necessary tools and tweaks:

```shell
qm start 9102
ssh ubuntu@10.0.7.50

sudo apt-get install glances iotop zsh jq ceph-common nethogs iperf qemu-guest-agent nfs-common
sudo rm /etc/resolv.conf
sudo ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf
shutdown -h "now"
exit

qm template 9102
```

## Create the nodes

Execute [create_nodes.sh](create_nodes.sh) on `proxmox` to create the 3 master and 3 worker nodes

## Cleanup

Execute [remove_nodes.sh](remove_nodes.sh) on `proxmox` to remove all the created nodes
