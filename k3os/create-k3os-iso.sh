#!/bin/bash

message() {
  echo -e "\n######################################################################"
  echo "# $1"
  echo "######################################################################"
}

need() {
    which "$1" &>/dev/null || die "Binary '$1' is missing but required"
}

usage() {
  echo "Run the script with '$0 <some node name>'"
  echo "e.g. '$0 k3os-b'"
  echo -e "the following node files are detected:\n"
  ls -1 nodes
  exit 1
}

need "wget"
need "grub-mkrescue"
need "sudo"

if [ $# -eq 0 ]
  then
    usage
else
  NODE="$1"
  if [ -f "nodes/$NODE.yaml" ]
    then
      echo "$NODE found"
    else
      usage
  fi
fi

export REPO_ROOT=$(git rev-parse --show-toplevel)
. "$REPO_ROOT"/.env

message "checking k3os-amd64.iso ISO file"

if [ -f "k3os-amd64.iso" ]
  then
    echo "k3os-amd64.iso already present, using that"
  else
    echo "no k3os-amd64.iso file present, downloading it now"
    wget https://github.com/rancher/k3os/releases/latest/download/k3os-amd64.iso
fi

message "checking temporary iso directory"

if [ -d "iso" ]
  then
    echo "iso directory present, using it for processing"
  else
    echo "iso directory not present, creating it and exploding contents to iso/ directory"
    sudo mkdir -p /mnt/iso
    sudo mount -o loop k3os-amd64.iso /mnt/iso
    mkdir -p iso/boot/grub
    cp -rf /mnt/iso/k3os iso/
    cp /mnt/iso/boot/grub/grub.cfg iso/boot/grub/
fi

message "copying $NODE configuration and baking ISO"
envsubst < "nodes/${NODE}.yaml" > iso/k3os/system/config.yaml
sudo cp grub.cfg iso/boot/grub/grub.cfg
grub-mkrescue -o "k3os-$NODE-configured.iso" iso/ -- -volid K3OS

message "k3os-$NODE-configured.iso ready for loading target node"
