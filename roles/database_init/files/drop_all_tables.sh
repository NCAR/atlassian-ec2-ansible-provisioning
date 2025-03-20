#!/bin/bash

# Drop all confluence tables

homedir=/var/atlassian/application-data/confluence

mycnf=$(/usr/local/bin/create_mycnf.sh)

script=$(mktemp)
echo 'SET FOREIGN_KEY_CHECKS = 0;' > $script
for t in $(mysql --defaults-file=$mycnf -sre "show tables;"); do
        echo "DROP TABLE IF EXISTS \`$t\`;" >> $script
done
echo 'SET FOREIGN_KEY_CHECKS = 1;' >> $script

mysql --defaults-file=$mycnf < $script
rm $script
rm $mycnf
