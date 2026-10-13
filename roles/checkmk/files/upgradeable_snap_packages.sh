#!/bin/bash

check_name='upgradeable_snap_packages'

tmpfile=$(mktemp)
snap refresh --list 2>/dev/null | awk '{print $1}' | grep -v '^Name' > $tmpfile
pkgs=$(paste -sd ',' $tmpfile)
rm $tmpfile
if test -z "$pkgs"; then
    echo "0 $check_name - No pending snap package updates"
else
    echo "1 $check_name - Pending snap package updates: $pkgs"
fi
