#!/bin/bash

#
# Create a mycnf defaults file from cloud-init env vars.
# This is completely general for all apps and avoids dealing with
# encrypted passwords in config files.
#

# Extract the relevant env vars from cloud-init.
# We do this convoluted temp file thing to get around quoting issues.
set_vars=$(mktemp)
for var in 'ATL_DB_CREDENTIAL_SECRET_ARN' 'ATL_DB_HOST' 'ATL_JDBC_DB_NAME'; do
    echo $(grep "export $var" /var/lib/cloud/instance/user-data.txt) >> $set_vars
done
. $set_vars
rm $set_vars

dbuser=$(aws secretsmanager get-secret-value --secret-id "$ATL_DB_CREDENTIAL_SECRET_ARN" --output text | awk '{print $4}' | jq -r .user)
dbpassword=$(aws secretsmanager get-secret-value --secret-id "$ATL_DB_CREDENTIAL_SECRET_ARN" --output text | awk '{print $4}' | jq -r .password)

mycnf=$(mktemp)
cat <<MYCNF >$mycnf
[client]
host=$ATL_DB_HOST
user=$dbuser
password='$dbpassword'
database=$ATL_JDBC_DB_NAME
MYCNF

echo $mycnf

