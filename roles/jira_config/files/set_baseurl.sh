#!/bin/bash

# REF: https://support.atlassian.com/jira/kb/change-the-base-url-of-jira-server-in-the-database/
#
# Set the base url forthe database; this is app-specific
#

baseurl=$1

if test -z $baseurl; then
    echo "Usage: $0 new_base_url"
    exit 1
fi

mycnf=$(/usr/local/bin/create_mycnf.sh)

mysql --defaults-file=$mycnf \
      -e "update propertystring, propertyentry set propertystring.propertyvalue = '$baseurl' where propertystring.ID = propertyentry.ID and propertyentry.PROPERTY_KEY = 'jira.baseurl';"

rm $mycnf

