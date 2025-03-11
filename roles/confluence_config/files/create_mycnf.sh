#!/bin/bash

# Create a mycnf defaults file for confluence

homedir="/var/atlassian/application-data/confluence"

database=$(perl -ne '$_ =~ m{jdbc:mysql://.*:\d+/(\w+)} && print $1;' $homedir/confluence.cfg.xml)
dbserver=$(grep hibernate.connection.url $homedir/confluence.cfg.xml | sed -e 's/.*mysql:\/\/\(.*\):.*/\1/')
dbuser=$(grep hibernate.connection.username $homedir/confluence.cfg.xml | sed -e 's/.*username">\(.*\)<.*/\1/')
dbpassword=$(grep hibernate.connection.password $homedir/confluence.cfg.xml | sed -e 's/.*password">\(.*\)<.*/\1/')

mycnf=$(mktemp)
cat <<MYCNF >$mycnf
[client]
host=$dbserver
user=$dbuser
password='$dbpassword'
database=$database
MYCNF

echo $mycnf
