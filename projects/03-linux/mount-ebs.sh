#!/usr/bin/env bash
# Projet 03 — étapes 7 et 8 : formate et monte un volume EBS vide sur /data, de façon persistante.
# Usage : sudo ./mount-ebs.sh /dev/nvme1n1
set -euo pipefail
DEV="${1:?Usage : sudo ./mount-ebs.sh /dev/nvme1n1  (voir lsblk)}"
MNT=/data
lsblk "$DEV"
if [ "$(file -sb "$DEV")" != "data" ]; then
  echo "ATTENTION : $DEV contient déjà un système de fichiers ($(file -sb "$DEV")). Abandon pour ne rien effacer."
  exit 1
fi
mkfs.ext4 -q "$DEV"
mkdir -p "$MNT"
UUID=$(blkid -s UUID -o value "$DEV")
grep -q "$UUID" /etc/fstab || echo "UUID=$UUID  $MNT  ext4  defaults,nofail  0  2" >> /etc/fstab
mount -a
df -h "$MNT"
