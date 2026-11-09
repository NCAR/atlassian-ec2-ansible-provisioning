#!/bin/bash
# Upgrade all apt and snap packages, and reboot
# Created by Ansible

echo ">>> ${0} Starting at $(date)"

echo ">>> Updating snap packages"
snap refresh

echo ">>>  Updating apt packages"
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get -y dist-upgrade

echo ">>>  Removing obsolete apt packages"
apt-get -y autoremove

echo ">>> Rebooting"
shutdown -r

echo ">>> ${0} Finished at $(date)"
