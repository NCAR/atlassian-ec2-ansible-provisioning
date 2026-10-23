#!/bin/bash

LOGDIR="/var/log/$(basename "$0" ".sh")"
if ! test -d $LOGDIR; then
    mkdir -p $LOGDIR
fi
DATESTR=$(date --iso-8601=second)
LOGFILE="${LOGDIR}/${DATESTR}.log"

echo "Logging to $LOGFILE"
exec > $LOGFILE 2>&1

echo ">>>>> ${0} Starting at $DATESTR <<<<<"

echo ">>>>> Updating snap packages <<<<<"
snap refresh

echo ">>>>> Updating apt packages <<<<<"
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get -y dist-upgrade
apt-get -y autoremove
systemctl daemon-reload

echo ">>>>> Rebooting <<<<<"
