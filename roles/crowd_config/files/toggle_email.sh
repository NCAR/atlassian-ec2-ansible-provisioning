#!/bin/bash

#
# Enable/disable outgoing email
#
# NOTE: this disables outgoing only
# REF: https://jira.atlassian.com/browse/CWD-6208
#

ACTION=$1

MAILSERVER_FILE=/var/mailserver

case $ACTION in
    'off')
	mycnf=$(/usr/local/bin/create_mycnf.sh)
	mailserver=$(mysql --defaults-file=$mycnf --batch -sre 'SELECT property_value FROM cwd_property WHERE property_name  = "mailserver.host";')
	if [ "$mailserver" == "localhost" ]; then
	    echo "Outgoing mail is already disabled"
	    rm $mycnf
	    exit 1
	fi
	
	echo $mailserver > $MAILSERVER_FILE
	mysql --defaults-file=$mycnf -e 'UPDATE cwd_property SET property_value = "localhost" WHERE property_name  = "mailserver.host";'
	rm $mycnf
	;;

    'on')
	if ! test -e $MAILSERVER_FILE; then
	    echo "Mailserver backup file \"$MAILSERVER_FILE\" doesn't exist; can't reset"
	    exit 1
	fi
	
	mycnf=$(/usr/local/bin/create_mycnf.sh)
	mailserver=$(mysql --defaults-file=$mycnf --batch -sre 'SELECT property_value FROM cwd_property WHERE property_name  = "mailserver.host";')
	if [ "$mailserver" != "localhost" ]; then
	    echo "Outgoing mail is already enabled; mailserver is: $mailserver"
	    rm $mycnf
	    exit 1
	fi

	mailserver=$(cat $MAILSERVER_FILE)
	mysql --defaults-file=$mycnf -e "UPDATE cwd_property SET property_value = '$mailserver' WHERE property_name  = 'mailserver.host';"
	rm $mycnf
	;;
    *)
	echo "Usage: $0 [on|off]"
	echo "Toggle outgoing email on/off via database query"
	exit 1
	;;
esac
