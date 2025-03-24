#!/bin/bash

# Enable/disable crowd recovery_admin user

ACTION=$1

homedir=/var/atlassian/application-data/crowd
setenv_file=/opt/atlassian/crowd/current/apache-tomcat/bin/setenv.sh

recovery_admin_search_line='# END ANSIBLE MANAGED CATALINA_OPTS'

case $ACTION in
    'enable')
	#
	# Enable recovery_admin user in setenv.sh
	#
	setenv_backup=$(dirname $setenv_file)/$(basename $setenv_file).$(date --iso-8601=seconds)
	cp $setenv_file $setenv_backup
	echo "setenv.sh file has been backed up to \"$setenv_backup\""
	
	recovery_admin_password=$(fgrep 'atlassian.recovery.password' $setenv_file | sed -e 's/.*password=\(.*\)[[:space:]].*/\1/')
	if ! test -z $recovery_admin_password; then
	    echo "Recovery admin user already enabled; password is: ${recovery_admin_password}"
	    echo "Check $homedir/logs/atlassian-crowd.log for line starting with \"Recovery admin username:\""
	else
	    recovery_admin_password=$(pwgen -s 32 1)
	    add_line='CATALINA_OPTS="-Datlassian.recovery.password='$recovery_admin_password' ${CATALINA_OPTS}"'
	    perl -i -spe 's/(\Q$recovery_admin_search_line\E)/$add_line\n$1/;' -- \
		 -recovery_admin_search_line="$recovery_admin_search_line" \
		 -add_line="$add_line" $setenv_file
	    echo "Recovery admin password is: $recovery_admin_password"
	    echo "Check $homedir/logs/atlassian-crowd.log for line starting with \"Recovery admin username:\" after restart"
	fi
	;;
    'disable')
	#
	# Disable recovery_admin user in setenv.sh
	#
	perl -i -lne 'print unless /\Q-Datlassian.recovery.password=\E/;' $setenv_file
	;;
    *)
	echo "Usage: $0 [enable|disable]"
	echo "Enable/disable crowd recovery_admin user."
	exit 1
	;;
esac


