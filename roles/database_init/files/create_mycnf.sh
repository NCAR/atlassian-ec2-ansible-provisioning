#!/bin/bash

#
# Create a mycnf defaults file from cloud-init env vars.
# This is completely general for all apps and avoids dealing with
# encrypted passwords in config files.
#

# Extract the relevant env vars from cloud-init.
# We do this convoluted temp file thing to get around quoting issues.
set_vars=$(mktemp)
for var in 'ATL_DBUSER_CREDENTIAL_SECRET_ARN' 'ATL_DB_HOST' 'ATL_JDBC_DB_NAME'; do
    echo $(grep "export $var" /var/lib/cloud/instance/user-data.txt) >> $set_vars
done
. $set_vars
rm $set_vars

secret_string=$(aws secretsmanager get-secret-value --secret-id "$ATL_DBUSER_CREDENTIAL_SECRET_ARN" --output json | jq -r '.SecretString')
dbuser=$(echo $secret_string | jq -r '.user')
dbpassword=$(echo $secret_string | jq -r '.password')

mycnf=$(mktemp)
cat <<MYCNF >$mycnf
[client]
host=$ATL_DB_HOST
user=$dbuser
password='$dbpassword'

[mysql]
database=$ATL_JDBC_DB_NAME
MYCNF

echo $mycnf

