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
  echo "e.g. '$0 k3s-b'"
  echo -e "the following node files are detected:\n"
  ls -1 nodes
  exit 1
}

need "scp"
need "envsubst"
need "cloud-localds"

if [ $# -eq 0 ]
  then
    usage
else
  NODE="$1"
  if [ -f "nodes/$NODE" ]
    then
      echo "node $NODE found"
    else
      usage
  fi
fi

export REPO_ROOT=$(git rev-parse --show-toplevel)
. "$REPO_ROOT"/.env

message "creating k3s-seed ISO for $NODE"
echo "touching meta-data file"
touch meta-data
echo "populating variables to temporary user-data file"
envsubst < "nodes/${NODE}" > "user-data"
echo "running 'cloud-localds k3s-seed-$NODE.iso user-data meta-data'"
cloud-localds k3s-seed-$NODE.iso user-data meta-data
rm user-data
rm meta-data
echo "copying seed ISO to proxmox"
scp k3s-seed-$NODE.iso root@proxmox:/tank/proxmox/template/iso/
