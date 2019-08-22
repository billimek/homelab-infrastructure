# Light-weight mixed-architecture cluster setup with k3s

## Kubernetes k3s nodes in proxmox

### PREREQUISITES

- Install terraform
  - Just download Terraform 0.11 from the [downloads page](https://releases.hashicorp.com/terraform/0.11.14/) and drop it somewhere in your $PATH
- Install the [Terraform Proxmox provider](https://github.com/Telmate/terraform-provider-proxmox) by running `./install_terraform_provider_proxmox.sh` (must have go installed already)
- Have a proxmox host

### Base template

On `proxmox` host OS,

Creating the base template from the ubuntu cloud-init image:

```shell
qm create 9101 --memory 4096 --net0 virtio,bridge=vmbr0
qm importdisk 9101 /tank/proxmox/template/iso/disco-server-cloudimg-amd64.img proxmox
qm set 9101 --scsihw virtio-scsi-pci --scsi0 proxmox:9101/vm-9101-disk-0.raw,ssd=1,discard=on
qm set 9101 --name disco-server-cloudimg-amd64
qm set 9101 --ide2 proxmox:cloudinit
qm set 9101 --boot c --bootdisk scsi0
qm set 9101 --serial0 socket --vga serial0
qm set 9101 --agent enabled=1,fstrim_cloned_disks=1
qm set 9101 --sshkey ~/.ssh/id_rsa.pub
qm set 9101 --ipconfig0 ip=10.0.7.50/24,gw=10.0.7.1
```

Install basic necessities to the VM template and fix /etc/resolve.conf

```shell
qm start 9101 && sleep 15 && ssh ubuntu@10.0.7.50
sudo apt-get install glances iotop zsh jq ceph-common nethogs iperf qemu-guest-agent nfs-common
sudo rm /etc/resolv.conf
sudo ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf
sudo shutdown -h "now"
qm template 9101
```

### Create the nodes

```shell
terraform init
terraform plan
terraform apply
```

## k3s

Instructions specific to k3s

## k3s master node installation

on the k3s 'master' k3s node, we tell flannel to use eth0:

```shell
curl -sfL https://get.k3s.io | sh -s - --no-deploy servicelb --flannel-iface=eth0
```

## k3s worker nodes installation

### amd64

```shell
curl -sfL https://get.k3s.io | K3S_URL=https://k3s-c:6443 K3S_TOKEN=<token from /var/lib/rancher/k3s/server/node-token> sh -
```

### arm (e.g. rpi4)

We add a node taint to prevent scheduling unless there is a tolartion in place. See [this comment](https://github.com/billimek/homelab-infrastructure/issues/2#issuecomment-522558754) for some background.

```shell
curl -sfL https://get.k3s.io | K3S_URL=https://k3s-c:6443 K3S_TOKEN=<token from /var/lib/rancher/k3s/server/node-token> sh -s - --node-taint arm=true:NoExecute
```
