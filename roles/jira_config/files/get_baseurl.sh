#!/bin/bash

# REF: https://support.atlassian.com/jira/kb/change-the-base-url-of-jira-server-in-the-database/
#
# Get the base url from the database; this is app-specific
#

mycnf=$(/usr/local/bin/create_mycnf.sh)
echo $(mysql --defaults-file=$mycnf --batch -Ne "select propertyvalue from propertyentry PE join propertystring PS on PE.id=PS.id where PE.property_key = 'jira.baseurl';")
rm $mycnf
