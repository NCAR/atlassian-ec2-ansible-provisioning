#!/bin/bash

#
# Install plugins after clone; uses appfire acli
#

USER=$1
PLUGINFILE=$2

if test -z $USER || test -z $PLUGINFILE; then
    cat << 'USAGE'
$0 admin_user plugin_file.json

Install plugins from plugin_file.json
Admin user's REST API token must be in environment variable $ATL_REST_TOKEN.
USAGE
   exit 1
fi

if ! test -e $PLUGINFILE; then
    echo "File $PLUGINFILE does not exist; should have been created by restore_for_clone.sh"
    exit 1
fi

if test -v $ATL_REST_TOKEN || test -z $ATL_REST_TOKEN; then
    echo "Environment variable ATL_REST_TOKEN not set or empty"
    exit 1
fi

export JAVA_HOME=$(java -XshowSettings:properties -version 2>&1 | perl -ne '/java\.home\s*=\s*(.*)/ && print $1')
BASE_CMD="acli --server $(/usr/local/bin/get_baseurl.sh) --user ${USER} --token $ATL_REST_TOKEN" 
for app_key in $(jq --raw-output 'keys | .[]' $PLUGINFILE); do
    echo ">>> Installing app $app_key"
    
    version=$(jq --raw-output ".\"${app_key}\".version" $PLUGINFILE)
    
    # Install 
    $BASE_CMD --action installApp --app $app_key --version $version --wait

    # License
    license=$(jq --raw-output ".\"${app_key}\".raw_license" $PLUGINFILE)
    if ! -z $license; then
	echo $license | $BASE_CMD --action addLicense --app $app_key --file "-"
    fi
	
    # Enable
    $BASE_CMD --action enableApp --app $app_key
done
