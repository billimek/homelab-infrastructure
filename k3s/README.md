# Light-weight mixed-architecture cluster setup with k3s

## VMs

See [proxmox instruction](proxmox.md) for creating the nodes.  Eventually this should be handled by terraform.

## k3s
Instructions specific to k3s

## k3s master
on the k3s 'master' k3s node (`k3s-c`)), we tell flannel to use eth0:

```shell
curl -sfL https://get.k3s.io | sh -s - --no-deploy servicelb --flannel-iface=eth0
```

## k3s worker nodes

### amd64

```shell
curl -sfL https://get.k3s.io | K3S_URL=https://k3s-c:6443 K3S_TOKEN=<token from /var/lib/rancher/k3s/server/node-token> sh -
```

### arm (e.g. rpi4)

We add a node taint to prevent scheduling unless there is a tolartion in place. See [this comment](https://github.com/billimek/homelab-infrastructure/issues/2#issuecomment-522558754) for some background.

```shell
curl -sfL https://get.k3s.io | K3S_URL=https://k3s-c:6443 K3S_TOKEN=<token from /var/lib/rancher/k3s/server/node-token> sh -s - --node-taint arm=true:NoExecute
```
