#!/bin/bash

nvme_devices=$(lsblk -N | grep '^nvme' | awk '{print $1}')

for n in $nvme_devices; do
    vol_id=$(ebsnvme-id "/dev/${n}" | grep -F 'Volume ID:' | awk '{print $3}') 
    mountpoint=$(aws ec2 describe-volumes --volume-ids $vol_id | jq -r '.Volumes[0].Tags[] | select(.Key == "mountpoint")["Value"]')
    if ! test -z "$mountpoint"; then
	uuid=$(blkid -o export "/dev/${n}" | grep UUID | awk -F= '{print $2}')
	echo "${uuid}:${mountpoint}"
    fi
done
