#!/bin/bash

#
# Get the base url from the database; this is app-specific
#


#
# Get the base url from the database; this is app
# used on clone restores to get the clone source base url
#
# This is app-specific
#

mycnf=$(/usr/local/bin/create_mycnf.sh)
echo $(mysql --defaults-file=$mycnf --batch -sre 'select BANDANAVALUE from BANDANA where BANDANACONTEXT = "_GLOBAL" and BANDANAKEY = "atlassian.confluence.settings";' | xmlstarlet select -t -v '/settings/baseUrl')
rm $mycnf



