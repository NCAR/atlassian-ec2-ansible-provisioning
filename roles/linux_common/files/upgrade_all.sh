#!/bin/bash
# Upgrade all apt and snap packages, and reboot
# Created by Ansible

LOGDIR="/var/log/$(basename "$0" ".sh")"
if ! test -d $LOGDIR; then
    mkdir -p $LOGDIR
fi
DATESTR=$(date --iso-8601=second)
LOGFILE="${LOGDIR}/${DATESTR}.log"

echo ">> Logging to $LOGFILE"

# Save original stdout and stderr
exec 3>&1 4>&2

# stdout and stderr to logfile
exec > $LOGFILE 2>&1

echo ">>>>> ${0} Starting at $DATESTR <<<<<"

echo ">>>>> Updating snap packages <<<<<"
snap refresh

echo ">>>>> Updating apt packages <<<<<"
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get -y dist-upgrade
apt-get -y autoremove

echo ">>>>> Rebooting <<<<<"

# Restore original stdout and stderr
exec 1>&3 2>&4 3>&- 4>&-

echo ">> Rebooting"
shutdown -r
