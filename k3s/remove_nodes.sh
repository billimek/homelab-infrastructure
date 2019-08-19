#!/bin/sh

qm stop 301 && qm destroy 301
ssh proxmox-b 'qm stop 302 && qm destroy 302'
ssh proxmox-c 'qm stop 303 && qm destroy 303'
