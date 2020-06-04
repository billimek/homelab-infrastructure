# Bootstrapping arm64 Raspberry Pi 4 nodes

## 64-bit arm ubuntu

See [this wiki for details](https://wiki.ubuntu.com/ARM/RaspberryPi)

### bootable image

Download the [20.04 arm64 image](http://cdimage.ubuntu.com/releases/focal/release/ubuntu-20.04-preinstalled-server-arm64+raspi.img.xz) and save to an SD card.  [etcher works well for this](https://www.balena.io/etcher/?ref=etcher_menu)

### manual setup

After flashing the image, re-mount the drive and copy the following files into `<drive>/system-boot/`:

* `user-data`
* `network-config`
* `cmdline.txt`

### scripted setup

This can be streamlined with the following script: `bootstrap-k3s.sh`:

```shell
./bootstrap-k3s.sh k3s-pi4-a /Volumes/system-boot
```

## boot into newly-provisioned ubuntu arm64 node with k3os

It will take some time for the [cloud-init](https://cloudinit.readthedocs.io/en/latest/index.html) settings above to execute, so you may need to wait a while (10 mins?) before attempting to ssh into the newly-provisioned node. as the 'ubuntu' user.  The new node should auto-join the k3s cluster.
