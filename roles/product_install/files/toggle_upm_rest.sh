#!/bin/bash

#
# Enable/disable REST API for installing plugins
# REF: https://help.moveworkforward.com/atlassian/2024-02-changes-to-the-installation-of-data-center
#

ACTION=$1


tomcat_var_file="{{ atl_jvm_custom_opts_dir }}/enable_upm_rest_api"

case $ACTION in
    'off')
	if ! test -e $tomcat_var_file; then
	    echo 'REST API already disabled for upm plugin install'
	else
	    rm $tomcat_var_file
	fi
	;;

    'on')
	if test -e $tomcat_var_file; then
	    echo 'REST API already enabled for upm plugin install'
	else
	    echo '-Dupm.plugin.upload.enabled=true' > $tomcat_var_file
	fi
	;;
    *)
	echo "Usage: $0 [on|off]"
	echo "Toggle REST API enabled for UPM plugin install on/off via tomcat args"
	exit 1
	;;
esac

