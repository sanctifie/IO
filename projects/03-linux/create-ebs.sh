#!/usr/bin/env bash
# Projet 03 — crée un volume EBS de 5 Go dans la même AZ que l'instance et l'attache (depuis ton poste).
# Usage : ./create-ebs.sh i-0123456789abcdef0
set -euo pipefail
IID="${1:?Usage : ./create-ebs.sh <instance-id>}"
AZ=$(aws ec2 describe-instances --instance-ids "$IID" --query 'Reservations[0].Instances[0].Placement.AvailabilityZone' --output text)
VOL=$(aws ec2 create-volume --size 5 --volume-type gp3 --availability-zone "$AZ" \
  --tag-specifications 'ResourceType=volume,Tags=[{Key=Project,Value=io-03},{Key=Name,Value=io-03-data}]' \
  --query VolumeId --output text)
aws ec2 wait volume-available --volume-ids "$VOL"
aws ec2 attach-volume --volume-id "$VOL" --instance-id "$IID" --device /dev/sdf > /dev/null
echo "Volume $VOL attaché à $IID ($AZ). Sur l'instance : lsblk puis sudo ./mount-ebs.sh /dev/nvme1n1"
echo "Nettoyage : aws ec2 detach-volume --volume-id $VOL && aws ec2 delete-volume --volume-id $VOL"
