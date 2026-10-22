#!/bin/bash

echo ">>>>> Updating snap packages <<<<<"
snap refresh

echo ">>>>> Updating apt packages <<<<<"
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get -y dist-upgrade
apt-get -y autoremove
systemctl daemon-reload

#
# This covers the kernel plus other related pkgs
# 
if test -e /var/run/reboot-required; then
    ">>>>> Reboot is required; rebooting <<<<<"
    shutdown -r
    exit
fi

restart_services=$(needrestart -b | grep NEEDRESTART-SVC | awk '{print $2}')
echo ">>>>> Restarting services: ${restart_services} <<<<<" 
systemctl restart $restart_services

