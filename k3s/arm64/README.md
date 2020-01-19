# Bootstrapping arm64 Raspberry Pi 4 nodes

## 64-bit arm ubuntu

See [this wiki for details](https://wiki.ubuntu.com/ARM/RaspberryPi)

### bootable image

Download the [19.10.1 arm64 image](http://cdimage.ubuntu.com/releases/eoan/release/ubuntu-19.10.1-preinstalled-server-arm64+raspi3.img.xz) and save to an SD card.  [etcher works well for this](https://www.balena.io/etcher/?ref=etcher_menu)

After flashing the image, re-mount the drive and copy the following files into `<drive>/system-boot/`:

* `user-data`
* `network-config`
* `nobtcmd.txt`

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
Mount the new drive:

```
sudo mount -a
```

After that, a reboot of the node is advisable.

After this, you should be able to 'join' the node to your k3s cluster.
