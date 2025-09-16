#!/bin/bash

#
# Install plugins after clone
#
PLUGINFILE=/tmp/plugins.json

USER=$1
if test -z $USER, then
   cat <<EOF 'USAGE'
$0 admin_user

Install plugins from $PLUGINFILE.
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

BASE_CMD="acli --server $(/usr/local/bin/get_baseurl.sh) --user ${USER} --token $ATL_REST_TOKEN" 
for app_key in $(jq --raw-output 'keys | .[]' $PLUGINFILE); do
    echo ">>> Installing app $app_key"
    
    version=$(jq --raw-output ".\"${app_key}\".version" $PLUGINFILE)
    license=$(jq --raw-output ".\"${app_key}\".raw_license" $PLUGINFILE)
    
    # Install 
    $BASE_CMD --action installApp --app $app_key --version $version --wait

    # License
    echo $license | $BASE_CMD --action addLicense --app $app_key --file "-"

    # Enable
    $BASE_CMD --action enableApp --app $app_key
done
