#
# Set the base url for the database; this is app-specific
#

baseurl=$1

if test -z $baseurl; then
    echo "Usage: $0 new_base_url"
    exit 1
fi

mycnf=$(/usr/local/bin/create_mycnf.sh)

mysql --defaults-file=$mycnf -e "UPDATE cwd_property SET property_value = '${baseurl} WHERE property_name = 'base.url';"

rm $mycnf
