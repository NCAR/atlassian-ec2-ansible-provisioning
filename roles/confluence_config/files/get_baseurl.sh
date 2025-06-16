#!/bin/bash

#
# Get the base url from the database--
# used on clone restores to get the clone source base url
#
# This is app-specific
#

mycnf=$(/usr/local/bin/create_mycnf.sh)
echo $(mysql --defaults-file=/tmp/tmp.I8lGP6D50A --batch -sre 'select BANDANAVALUE from BANDANA where BANDANACONTEXT = "_GLOBAL" and BANDANAKEY = "atlassian.confluence.settings";' | xmlstarlet select -t -v '/settings/baseUrl')
rm $mycnf



