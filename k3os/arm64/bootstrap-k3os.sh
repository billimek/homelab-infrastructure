#!/bin/bash

message() {
  echo -e "\n######################################################################"
  echo "# $1"
  echo "######################################################################"
}

if [ $# -eq 0 ]
  then
    echo "No node name supplied: rall the script with '$0 <some node name> (optional <some target path>)'"
    echo "e.g. '$0 user-data-k3os-pi4-a /Volumes/system-boot'"
    exit 1
else
  NODE="$1"
  if [ -f "$NODE" ]
    then
      echo "$NODE found"
    else
      echo "'$NODE' user-data file not found, the following casndidates were deetected, however:"
      ls -1 user-data*
      echo -e "\nRun the script with '$0 <some node name> (optional <some target path>)'"
      echo "e.g. '$0 user-data-k3os-pi4-a /Volumes/system-boot'"
      exit 1
  fi
fi

if [ -z "$2" ]
  then
    # check if the ubuntu system-boot volume is already present in the default location
    if [ -f /Volumes/system-boot/cmdline.txt ]
      then
        echo "Assuming /Volumes/system-boot as the target"
        TARGET_VOLUME="/Volumes/system-boot"
      else
        echo "No path given as a target. Call the script with '$0 <some node name> <some target path>'"
        exit 1
    fi
else
  TARGET_VOLUME="$2"
fi

export REPO_ROOT=$(git rev-parse --show-toplevel)
. "$REPO_ROOT"/.env

message "writing $NODE configuration to $TARGET_VOLUME"

echo "copying cmdline.txt to $TARGET_VOLUME/cmdline.txt"
cp -f cmdline.txt "$TARGET_VOLUME/cmdline.txt"
echo "copying ${NODE} to $TARGET_VOLUME/user-data"
envsubst < "${NODE}" > "$TARGET_VOLUME/user-data"
