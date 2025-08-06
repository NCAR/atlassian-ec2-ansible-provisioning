#!/bin/bash

#
# Set the base url for the database; this is app-specific
#

baseurl=$1

if test -z $baseurl; then
    echo "Usage: $0 new_base_url"
    exit 1
fi

mycnf=$(/usr/local/bin/create_mycnf.sh)

mysql --defaults-file=$mycnf -e "UPDATE BANDANA SET BANDANAVALUE = UPDATEXML(BANDANAVALUE, '/settings/baseUrl', '<baseUrl>$baseurl</baseUrl>') WHERE BANDANAKEY = 'atlassian.confluence.settings'";

rm $mycnf
