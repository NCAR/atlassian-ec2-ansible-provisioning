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

xml=$(mktemp)

mysql --defaults-file=$mycnf --batch -sre 'select BANDANAVALUE from BANDANA where BANDANACONTEXT = "_GLOBAL" and BANDANAKEY = "atlassian.confluence.settings";' > $xml

xmlstarlet ed --inplace --update '/settings/baseUrl' --value $baseurl $xml

mysql --defaults-file=$mycnf -e "update BANDANA set BANDANAVALUE = '$(cat $xml)' where BANDANACONTEXT = '_GLOBAL' and BANDANAKEY = 'atlassian.confluence.settings';"

rm $xml
rm $mycnf
