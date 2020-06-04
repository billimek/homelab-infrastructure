# k3os bootstrapping

**Due to [issues](https://github.com/billimek/homelab-infrastructure/issues/19) with k3os on raspberry pi devices and odroid-h2 devices, will not be using k2os as the base OS for k3s node, for now**

## 'regular' amd64/VM nodes

Following the [bootstrapping ISO](https://github.com/rancher/k3os#remastering-iso) installation method:

### helper script

Run `[create-k3os-iso.sh](create-k3os-iso.sh)` script to automatically create configured ISO for loading to target node/VM

### manual steps

* Download latest k3os amd64 ISO:

```sh
wget https://github.com/rancher/k3os/releases/latest/download/k3os-amd64.iso
```

* Explode the ISO for editing to bootstrap custom configuration:

```sh
sudo mkdir -p /mnt/iso
sudo mount -o loop k3os-amd64.iso /mnt/iso
mkdir -p iso/boot/grub
cp -rf /mnt/iso/k3os iso/
cp /mnt/iso/boot/grub/grub.cfg iso/boot/grub/
```

* Copy edited files to iso staging directory (where `config.yaml` is a populated yaml file, see [nodes/](nodes/) directory for examples):

```sh
sudo cp nodes/k3os-b.yaml iso/k3os/system/config.yaml
sudo cp grub.cfg iso/boot/grub/grub.cfg
```

* 'bake' configured ISO for future use:

```sh
grub-mkrescue -o k3os-k3os-b-configured.iso iso/ -- -volid K3OS
```

## odroid-h2

The **odroid-h2** device has difficulty booting k3os due to issues with secure boot and EFI.  An approach which works for installing k3os on an odroid-h2 device is to first install a bootable OS (e.g. ubuntu 20.04 server), followed by the k3os [overlay installation](https://github.com/rancher/k3os#arm-overlay-installation) (ignore the part about it being for arm - this works on amd64 as well) as follows:

Copy prepared k3os config file to odroid host:

```shell
envsubst < configs/config-worker-odroid.yaml | ssh ubuntu@<odroid host> "cat > config.yaml"
```

Log-in to odroid host and run k3os overlay installation:

```shell
ssh ubuntu@<odroid host>
sudo -i
curl -sfL https://github.com/rancher/k3os/releases/latest/download/k3os-rootfs-amd64.tar.gz | tar zxvf - --strip-components=1 -C /
cp ~ubnutu/config.yaml /k3os/system/config.yaml
sync
reboot
```

## arm64

See [arm64](arm64/) directory for specific instructions
