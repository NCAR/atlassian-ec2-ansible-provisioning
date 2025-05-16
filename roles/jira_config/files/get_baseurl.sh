#
# Get the base url from the database--
# used on clone restores to get the clone source base url
#
# This is app-specific
#

mycnf=$(/usr/local/bin/create_mycnf.sh)
echo $(mysql --defaults-file=$mycnf --batch -Ne "select propertyvalue from propertyentry PE join propertystring PS on PE.id=PS.id where PE.property_key = 'jira.baseurl';")
rm $mycnf
