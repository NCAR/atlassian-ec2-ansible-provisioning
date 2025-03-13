#!/bin/bash

# Enable/disable confluence recovery_admin user

ACTION=$1

homedir=/var/atlassian/application-data/confluence
setenv_file=/opt/atlassian/confluence/current/bin/setenv.sh

recovery_admin_search_line='CATALINA_OPTS="${START_CONFLUENCE_JAVA_OPTS} ${CATALINA_OPTS}"'

case $ACTION in
    'enable')
	bandanaval='true'

	#
	# Enable recovery_admin user in setenv.sh
	#
	recovery_admin_password=$(fgrep 'atlassian.recovery.password' $setenv_file | sed -e 's/.*password=\(.*\)[[:space:]].*/\1/')
	if ! test -z $recovery_admin_password; then
	    echo "recovery_admin user already enabled; password is: ${recovery_admin_password}"
	else
	    recovery_admin_password=$(pwgen -s 32 1)
	    add_line='CATALINA_OPTS="-Datlassian.recovery.password='$recovery_admin_password' ${CATALINA_OPTS}"'
	    perl -i -spe 's/(\Q$recovery_admin_search_line\E)/$add_line\n$1/;' -- \
		 -recovery_admin_search_line="$recovery_admin_search_line" \
		 -add_line="$add_line" $setenv_file
	    echo "recovery_admin password is: $recovery_admin_password"
	fi
	;;
    'disable')
	bandanaval='false'

	#
	# Disable recovery_admin user in setenv.sh
	#
	perl -i -lne 'print unless /\Q-Datlassian.recovery.password=\E/;' $setenv_file
	;;
    *)
	echo "Usage: $0 [enable|disable]"
	echo "Enable/disable confluence recovery_admin user."
	exit 1
	;;
esac

mycnf=$(/usr/local/bin/create_mycnf.sh)
mysql --defaults-file=$mycnf -e "UPDATE BANDANA SET BANDANAVALUE='<string>${bandanaval}</string>' WHERE BANDANAKEY='com.atlassian.plugins.authentication.sso.config.enable-authentication-fallback';"
rm $mycnf

