#!/bin/bash

#
# Enable/disable jira recovery_admin user
# REF: https://confluence.atlassian.com/jirakb/restore-passwords-to-recover-admin-user-rights-972329273.html
#
# WARNING
# - any other args in JVM_SUPPORT_RECOMMENDED_ARGS will be lost
# - any disabled directories will be reenabled if action is "disable"
#

ACTION=$1

homedir=/var/atlassian/application-data/jira
setenv_file=/opt/atlassian/jira-core/current/bin/setenv.sh

recovery_admin_search_re='^JVM_SUPPORT_RECOMMENDED_ARGS=.*$'

case $ACTION in
    'enable')
	# Toggle internal directory on, external off
	# REF: https://confluence.atlassian.com/jirakb/disabling-a-directory-via-the-jira-database-338366836.html
	mycnf=$(/usr/local/bin/create_mycnf.sh)
	mysql --defaults-file=$mycnf -e "UPDATE cwd_directory SET active = 1 WHERE lower_directory_name LIKE '%internal%';"
	mysql --defaults-file=$mycnf -e "UPDATE cwd_directory SET active = 0 WHERE lower_directory_name NOT LIKE '%internal%';"

	# Toggle enable-authentication-fallback on
	# REF: https://confluence.atlassian.com/jirakb/bypass-saml-authentication-for-jira-data-center-869009810.html
	mysql --defaults-file=$mycnf -e "UPDATE propertystring SET propertyvalue = 'true' WHERE ID = (SELECT ID FROM propertyentry WHERE PROPERTY_KEY LIKE 'com.atlassian.plugins.authentication.sso.config.enable-authentication-fallback');"
	
	rm $mycnf
	
	#
	# Enable recovery_admin user in setenv.sh
	#
	setenv_backup=$(dirname $setenv_file)/$(basename $setenv_file).$(date --iso-8601=seconds)
	cp $setenv_file $setenv_backup
	echo "setenv.sh file has been backed up to \"$setenv_backup\""
	
	recovery_admin_password=$(fgrep 'atlassian.recovery.password' $setenv_file | sed -e 's/.*password=\(.*\)[[:space:]].*/\1/')
	if ! test -z $recovery_admin_password; then
	    echo "recovery_admin user already enabled; password is: ${recovery_admin_password}"
	else
	    recovery_admin_password=$(pwgen -s 32 1)
	    add_line="JVM_SUPPORT_RECOMMENDED_ARGS=\"-Datlassian.recovery.password='$recovery_admin_password' -Datlassian.authentication.legacy.mode=true\""
	    perl -i -spe 's/$recovery_admin_search_re/$add_line\n$1/;' -- \
		 -recovery_admin_search_re="$recovery_admin_search_re" \
		 -add_line="$add_line" $setenv_file
	    echo "recovery_admin password is: $recovery_admin_password"
	fi
	echo "Recovery admin username is shown on login page."
	;;
    'disable')
	# Toggle internal directory off, external on
	# WARNING this is NOT necessarily setting it back to its original state
	mycnf=$(/usr/local/bin/create_mycnf.sh)
#	mysql --defaults-file=$mycnf -e "UPDATE cwd_directory SET active = 0 WHERE lower_directory_name LIKE '%internal%';"
#	mysql --defaults-file=$mycnf -e "UPDATE cwd_directory SET active = 1 WHERE lower_directory_name NOT LIKE '%internal%';"

	# Toggle enable-authentication-fallback off
	# REF: https://confluence.atlassian.com/jirakb/bypass-saml-authentication-for-jira-data-center-869009810.html
	mysql --defaults-file=$mycnf -e "UPDATE propertystring SET propertyvalue = 'false' WHERE ID = (SELECT ID FROM propertyentry WHERE PROPERTY_KEY LIKE 'com.atlassian.plugins.authentication.sso.config.enable-authentication-fallback');"

	rm $mycnf
	
	#
	# Disable recovery_admin user in setenv.sh
	#
	cwd_directory_active=1
	add_line='JVM_SUPPORT_RECOMMENDED_ARGS=""'
	perl -i -spe 's/$recovery_admin_search_re/$add_line\n$1/;' -- \
	     -recovery_admin_search_re="$recovery_admin_search_re" \
	     -add_line="$add_line" $setenv_file
	;;
    *)
	echo "Usage: $0 [enable|disable]"
	echo "Enable/disable jira recovery_admin user."
	exit 1
	;;
esac


