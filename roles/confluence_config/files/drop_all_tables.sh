#!/bin/bash

# Drop all confluence tables

homedir=/var/atlassian/application-data/confluence

database=$(grep hibernate.connection.url $homedir/confluence.cfg.xml | sed -e 's/.*\/\(.*\)<.*/\1/')
dbserver=$(grep hibernate.connection.url $homedir/confluence.cfg.xml | sed -e 's/.*mysql:\/\/\(.*\):.*/\1/')
dbuser=$(grep hibernate.connection.username $homedir/confluence.cfg.xml | sed -e 's/.*username">\(.*\)<.*/\1/')
dbpassword=$(grep hibernate.connection.password $homedir/confluence.cfg.xml | sed -e 's/.*password">\(.*\)<.*/\1/')

mycnf=$(mktemp); chmod 700 $mycnf;
cat <<EOF >$mycnf
[client]
host=$dbserver
user=$dbuser
password='$dbpassword'
EOF

script=$(mktemp)
echo 'use confluence;' >> $script
echo 'SET FOREIGN_KEY_CHECKS = 0;' >> $script
for t in $(mysql --defaults-file=/tmp/mycnf -sre "use confluence; show tables;"); do
        echo "DROP TABLE IF EXISTS \`$t\`;" >> $script
done
echo 'SET FOREIGN_KEY_CHECKS = 1;' >> $script

mysql --defaults-file=/tmp/mycnf < $script
rm $script
rm $mycnf
