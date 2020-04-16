# k3os bootstrapping

Following the [bootstrapping ISO](https://github.com/rancher/k3os#remastering-iso) installation method:

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

**Edit `grub.cfg` and `config.yaml`**

* Copy edited files to iso staging directory:

```sh
sudo cp config.yaml iso/k3os/system/config.yaml
sudo cp grub.cfg iso/boot/grub/grub.cfg
```

* 'bake' configured ISO for future use:

```sh
grub-mkrescue -o k3os-configured.iso iso/ -- -volid K3OS
```
