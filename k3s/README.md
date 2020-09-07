# Light-weight mixed-architecture cluster setup with k3s

## Physical devices (amd64)

Based on all of my investigation, as of 2020-06-04:

* The Ubuntu 20.04 [autoinstaller](https://wiki.ubuntu.com/FoundationsTeam/AutomatedServerInstalls/) simply doesn't work and/or is far too buggy to reliably use, after dozens of attempts to make it work properly in a test setup
* There doesn't seem to be a path forward to installing Ubuntu 20.04 server in a generic way that also leverages cloud-init, like we do for VMs are raspberry pi devices
* The 'best' approach is to manually run through the Ubuntu 20.04 'live server' installer ISO (from USB), manually configure the server settings; followed by hand-crafting post-installation changes that we would normally do via cloud-init

The only physical device in my current compute environment is an Odroid-H2.  The plan will be to install Ubuntu Live Server 20.04 via a USB, apply the normal cloud-init changes manually, and then install k3s manually.

## arm64 (raspberry pi4)

See [arm64/README.md](arm64/README.md) instructions for bootstrapping ARM64-based raspberry pi nodes

## Proxmox

A VM template is created from the [ubuntu cloudimg image source](https://cloud-images.ubuntu.com/focal/current/), and k3s nodes are created from that template with the necessary cloud-init data being passed-in as a cdrom device via a previously configured ISO.

### Base template

**This is a "one time" activity**

On `proxmox` host OS,

Creating the base template from the ubuntu cloud-init image:

```shell
qm create 9200 --name focal-server-cloudimg-amd64 --memory 4096 --cpu cputype=host --cores 4 --serial0 socket --vga serial0 --net0 virtio,bridge=vmbr0,tag=20 --agent enabled=1,fstrim_cloned_disks=1
qm importdisk 9200 /tank/proxmox/template/iso/focal-server-cloudimg-amd64.img proxmox -format qcow2
qm set 9200 --scsihw virtio-scsi-pci --scsi0 proxmox:9200/vm-9200-disk-0.qcow2,ssd=1,discard=on
qm template 9200
```

### Create node-specific cloud-init seed ISO

Leverage the [`cloud-localds`](https://manpages.debian.org/testing/cloud-image-utils/cloud-localds.1.en.html) tool to inject cloud-init user-data to a special ISO be consumed by the cloudimg.  This generated ISO, when added to the VM, will automatically be detected and used by first boot to run the cloud-init instructions.  This was intentionally done vs using the builtin proxmox cloud-init approach becuase there is more that can be manipulated with the 'raw' cloud-init.

See [`create-k3s-seed-iso.sh`](create-k3s-seed-iso.sh) script for details on how this is is done.

### clone from template

For each 'node' that needs to be created,

* clone to a new VM
* resize the hard drive to the new desired size
* force booting from the new drive
* add the seed ISO file to the VM

For example, for node `k3s-c`, we create VM ID 402 by running the following:

```shell
qm clone 9200 402 --name k3s-c --format raw --full --storage zfs-prox
qm resize 402 scsi0 200G
qm set 402 --boot c --bootdisk scsi0
qm set 402 -cdrom /mnt/pve/proxmox/template/iso/k3s-seed-k3s-c.iso
qm migrate 402 proxmox-c --with-local-disks --online
```

### customize the created node

Make any required changes to the newly-created VM.  This will be things like:

* adjusting cores
* adjusting memory
* adding real physical drives to the VM (e.g. for ceph OSDs)
* adding any GPU passthrough devices

## k3s

See [the k3s bootstrap instuctions](https://github.com/billimek/k8s-gitops/blob/master/setup/README.md) for more detail.
