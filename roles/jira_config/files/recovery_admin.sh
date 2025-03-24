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
	#
	# Enable recovery_admin user in setenv.sh
	#
	cwd_directory_active=0

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
	;;
    'disable')
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

# REF: https://confluence.atlassian.com/jirakb/disabling-a-directory-via-the-jira-database-338366836.html
mycnf=$(/usr/local/bin/create_mycnf.sh)
mysql --defaults-file=$mycnf -e "UPDATE cwd_directory SET active = $cwd_directory_active WHERE id != 1";
rm $mycnf

