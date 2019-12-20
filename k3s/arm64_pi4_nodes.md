# Bootstrapping an arm64 Raspberry Pi 4 node

## 64-bit arm ubuntu

See [this wiki for details](https://wiki.ubuntu.com/ARM/RaspberryPi)

### bootable image

Download the [19.10.1 arm64 image](http://cdimage.ubuntu.com/releases/eoan/release/ubuntu-19.10.1-preinstalled-server-arm64+raspi3.img.xz) and save to an SD card.  [etcher works well for this](https://www.balena.io/etcher/?ref=etcher_menu)

### tweak image settings in `system-boot/user-data`

Edit the `system-boot/user-data` file on the freshly-flashed drive and alter the following:

* uncomment `package_update: true`
* uncomment `package_upgrade: true`
* Add the following to the file to install some necessary packages:

```shell
packages:
- curl
- wget
- htop
- glances
- nfs-common
```

* Add the following to the file to fix nslookups, set the hostname (set this to something appropriate), and install netdata:

**NOTE: be sure to change the hostname as appropriate per host below in the `hostnamectl` command**

```shell
runcmd:
- ln -sfn /run/systemd/resolve/resolv.conf /etc/resolv.conf
- hostnamectl set-hostname pi4-a
- 'curl -Ss https://my-netdata.io/kickstart.sh | /bin/bash -s -- --dont-wait'
```

### enable cgroup settings in `system-boot/nobtcmd.txt`

Append the following to the end of the line in the `system-boot/nobtcmd.txt` file: `cgroup_memory=1 cgroup_enable=memory`

### (OPTIONAL) add vlan(s) for networking in `system-boot/network-config`

If it is desired to run the pi in a dedicated vlan, edit `system-boot/network-config` and change the contents to something like this:

```netplan
ethernets:
  eth0:
    dhcp4: false
    optional: true
version: 2
vlans:
  vlan.20:
    dhcp4: true
    id: 20
    link: eth0
```

## boot into newly-provisioned ubuntu arm64 node

It will take some time for the [cloud-init](https://cloudinit.readthedocs.io/en/latest/index.html) settings above to execute, so you may need to wait a while (10 mins?) before attempting to ssh into the newly-provisioned node.

The default username password is ubuntu/ubuntu.  Upon first login, you will be required to change the password.  

### (OPTIONAL) provision external storage

Idenfity the UUID of the external storage device,

```
ls -al /dev/disk/by-uuid/
```

Add the following to `/etc/fstab` with the device info (e.g. if the uuid is `cf43ce16-c002-4222-9c92-787cf70e20dc`):

```
sudo vim /etc/fstab
```

Add the new entry to the file:

```
UUID=cf43ce16-c002-4222-9c92-787cf70e20dc /mnt/usb ext4 defaults 1 2
```

Make sure the point point exists:

```
sudo mkdir -p /mnt/usb
```

Mount the new drive:

```
sudo mount -a
```

After that, a reboot of the node is advisable.

After this, you should be able to 'join' the node to your k3s cluster.
