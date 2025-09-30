#!/bin/bash

#
# Confluence stalls for several minutes during startup waiting for a lock, see:
# https://support.atlassian.com/confluence/kb/confluence-upgrade-failed-with-liquibaseexceptionlockexception-could-not-acquire-change-log-lock-error/

mycnf=$(/usr/local/bin/create_mycnf.sh)
mysql --defaults-file=$mycnf -e 'UPDATE MIG_DB_CHANGELOG_LOCK SET LOCKED=0, LOCKGRANTED=null, LOCKEDBY=null where ID=1;'
rm $mycnf

