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
export PM_PASS=<your_proxmox_terraform_password_here>
terraform init
terraform plan
terraform apply
```

## Kubernetes k3s nodes on arm devices

See [arm64/README.md](arm64/README.md) instructions for bootstrapping ARM64-based raspberry pi nodes

## k3s

See [the k3s bootstrap instuctions](https://github.com/billimek/k8s-gitops/blob/master/setup/README.md) for more detail.
